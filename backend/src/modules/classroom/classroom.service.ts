import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '@/prisma/prisma.service';
import { generateCode } from '@/common/utils/generate-code';
import {
  CreateClassroomDto,
  UpdateClassroomDto,
  JoinClassroomDto,
  ClassroomQueryDto,
} from './dto';

const CODE_MAX_RETRIES = 5;

const STUDENT_SELECT = {
  id: true,
  email: true,
  adSoyad: true,
  cityId: true,
  districtId: true,
  city: { select: { id: true, name: true } },
  district: { select: { id: true, name: true } },
  createdAt: true,
} as const;

@Injectable()
export class ClassroomService {
  private readonly logger = new Logger(ClassroomService.name);

  constructor(private prisma: PrismaService) {}

  // ─── Teacher: Classroom CRUD ────────────────────────────────────────────

  async createClassroom(teacherId: string, dto: CreateClassroomDto) {
    const code = await this.generateUniqueCode();
    const classroom = await this.prisma.classroom.create({
      data: { name: dto.name, code, teacherId },
      include: { _count: { select: { students: true } } },
    });
    this.logger.log(`Classroom created: ${classroom.id} (${code}) by teacher ${teacherId}`);
    return classroom;
  }

  async getMyClassrooms(teacherId: string) {
    return this.prisma.classroom.findMany({
      where: { teacherId },
      include: { _count: { select: { students: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getClassroomDetail(teacherId: string, classroomId: string, query: ClassroomQueryDto) {
    await this.verifyTeacherOwnsClassroom(teacherId, classroomId);

    const { search, page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.ClassroomStudentWhereInput = { classroomId };
    if (search) {
      where.student = {
        OR: [
          { adSoyad: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      };
    }

    const [classroom, members, total] = await Promise.all([
      this.prisma.classroom.findUnique({
        where: { id: classroomId },
        include: { _count: { select: { students: true } } },
      }),
      this.prisma.classroomStudent.findMany({
        where,
        include: { student: { select: STUDENT_SELECT } },
        skip,
        take: limit,
        orderBy: { joinedAt: 'desc' },
      }),
      this.prisma.classroomStudent.count({ where }),
    ]);

    const students = members.map((m) => ({ joinedAt: m.joinedAt, ...m.student }));

    return {
      classroom,
      students,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async updateClassroom(teacherId: string, classroomId: string, dto: UpdateClassroomDto) {
    await this.verifyTeacherOwnsClassroom(teacherId, classroomId);
    return this.prisma.classroom.update({
      where: { id: classroomId },
      data: dto,
      include: { _count: { select: { students: true } } },
    });
  }

  async deleteClassroom(teacherId: string, classroomId: string) {
    await this.verifyTeacherOwnsClassroom(teacherId, classroomId);
    await this.prisma.classroom.delete({ where: { id: classroomId } });
    this.logger.log(`Classroom deleted: ${classroomId} by teacher ${teacherId}`);
    return { message: 'Sınıf silindi' };
  }

  async regenerateCode(teacherId: string, classroomId: string) {
    await this.verifyTeacherOwnsClassroom(teacherId, classroomId);
    const code = await this.generateUniqueCode();
    await this.prisma.classroom.update({ where: { id: classroomId }, data: { code } });
    this.logger.log(`Code regenerated for classroom ${classroomId}`);
    return { code };
  }

  // ─── Teacher: Student management ────────────────────────────────────────

  async getStudentInClassroom(teacherId: string, classroomId: string, studentId: string) {
    await this.verifyTeacherOwnsClassroom(teacherId, classroomId);

    const membership = await this.prisma.classroomStudent.findUnique({
      where: { classroomId_studentId: { classroomId, studentId } },
    });
    if (!membership) {
      throw new NotFoundException('Bu öğrenci bu sınıfta bulunmuyor');
    }

    const student = await this.prisma.user.findUnique({
      where: { id: studentId },
      select: {
        ...STUDENT_SELECT,
        results: {
          include: {
            test: { include: { section: { include: { book: true } } } },
            answers: { include: { question: { include: { learningOutcome: true } } } },
          },
          orderBy: { createdAt: 'desc' },
          take: 50,
        },
        analytics: {
          include: { section: { include: { book: true } } },
          orderBy: { accuracy: 'asc' },
        },
      },
    });

    if (!student) {
      throw new NotFoundException('Öğrenci bulunamadı');
    }

    return { ...student, joinedAt: membership.joinedAt };
  }

  async removeStudentFromClassroom(teacherId: string, classroomId: string, studentId: string) {
    await this.verifyTeacherOwnsClassroom(teacherId, classroomId);

    const membership = await this.prisma.classroomStudent.findUnique({
      where: { classroomId_studentId: { classroomId, studentId } },
    });
    if (!membership) {
      throw new NotFoundException('Bu öğrenci bu sınıfta bulunmuyor');
    }

    await this.prisma.classroomStudent.delete({ where: { id: membership.id } });
    this.logger.log(`Student ${studentId} removed from classroom ${classroomId}`);
    return { message: 'Öğrenci sınıftan çıkarıldı' };
  }

  // ─── Student actions ────────────────────────────────────────────────────

  async joinClassroom(studentId: string, dto: JoinClassroomDto) {
    const classroom = await this.prisma.classroom.findUnique({
      where: { code: dto.code },
      include: { teacher: { select: { id: true, adSoyad: true, okul: true } } },
    });

    if (!classroom) {
      throw new NotFoundException('Bu kodla bir sınıf bulunamadı');
    }

    const existing = await this.prisma.classroomStudent.findUnique({
      where: { classroomId_studentId: { classroomId: classroom.id, studentId } },
    });

    if (existing) {
      throw new ConflictException('Bu sınıfa zaten kayıtlısınız');
    }

    await this.prisma.classroomStudent.create({
      data: { classroomId: classroom.id, studentId },
    });

    this.logger.log(`Student ${studentId} joined classroom ${classroom.id}`);

    return {
      message: 'Sınıfa başarıyla katıldınız',
      classroom: {
        id: classroom.id,
        name: classroom.name,
        teacher: classroom.teacher,
      },
    };
  }

  async getStudentClassrooms(studentId: string) {
    const memberships = await this.prisma.classroomStudent.findMany({
      where: { studentId },
      include: {
        classroom: {
          include: {
            teacher: { select: { id: true, adSoyad: true, okul: true } },
            _count: { select: { students: true } },
          },
        },
      },
      orderBy: { joinedAt: 'desc' },
    });

    return memberships.map((m) => ({ joinedAt: m.joinedAt, ...m.classroom }));
  }

  async leaveClassroom(studentId: string, classroomId: string) {
    const membership = await this.prisma.classroomStudent.findUnique({
      where: { classroomId_studentId: { classroomId, studentId } },
    });

    if (!membership) {
      throw new NotFoundException('Bu sınıfa kayıtlı değilsiniz');
    }

    await this.prisma.classroomStudent.delete({ where: { id: membership.id } });
    this.logger.log(`Student ${studentId} left classroom ${classroomId}`);
    return { message: 'Sınıftan ayrıldınız' };
  }

  // ─── Private helpers ────────────────────────────────────────────────────

  private async verifyTeacherOwnsClassroom(teacherId: string, classroomId: string) {
    const classroom = await this.prisma.classroom.findUnique({
      where: { id: classroomId },
    });
    if (!classroom) {
      throw new NotFoundException('Sınıf bulunamadı');
    }
    if (classroom.teacherId !== teacherId) {
      throw new ForbiddenException('Bu sınıfa erişim yetkiniz yok');
    }
    return classroom;
  }

  private async generateUniqueCode(): Promise<string> {
    for (let attempt = 0; attempt < CODE_MAX_RETRIES; attempt++) {
      const code = generateCode(8);
      const existing = await this.prisma.classroom.findUnique({ where: { code } });
      if (!existing) return code;
      this.logger.warn(`Classroom code collision on attempt ${attempt + 1}: ${code}`);
    }
    throw new ConflictException('Kod üretilemedi, lütfen tekrar deneyin');
  }
}
