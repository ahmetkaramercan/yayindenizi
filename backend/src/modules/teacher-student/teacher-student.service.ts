import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { Role, Prisma } from '@prisma/client';
import { PrismaService } from '@/prisma/prisma.service';
import { AddTeacherDto, StudentQueryDto } from './dto';

const STUDENT_SELECT = {
  id: true,
  email: true,
  adSoyad: true,
  il: true,
  ilce: true,
  createdAt: true,
} as const;

const TEACHER_SELECT = {
  id: true,
  email: true,
  adSoyad: true,
  ogretmenKodu: true,
  okul: true,
  il: true,
  ilce: true,
} as const;

@Injectable()
export class TeacherStudentService {
  private readonly logger = new Logger(TeacherStudentService.name);

  constructor(private prisma: PrismaService) {}

  // ─── Student actions ───────────────────────────────────────────────────

  async addTeacher(studentId: string, dto: AddTeacherDto) {
    const teacher = await this.prisma.user.findUnique({
      where: { ogretmenKodu: dto.ogretmenKodu, role: Role.TEACHER },
      select: TEACHER_SELECT,
    });

    if (!teacher) {
      throw new NotFoundException('Bu kodla bir öğretmen bulunamadı');
    }

    const existing = await this.prisma.teacherStudent.findUnique({
      where: { teacherId_studentId: { teacherId: teacher.id, studentId } },
    });

    if (existing) {
      throw new ConflictException('Bu öğretmenle zaten bağlantılısınız');
    }

    await this.prisma.teacherStudent.create({
      data: { teacherId: teacher.id, studentId },
    });

    this.logger.log(`Student ${studentId} added teacher ${teacher.id}`);

    return {
      message: 'Öğretmen başarıyla eklendi',
      teacher: {
        id: teacher.id,
        adSoyad: teacher.adSoyad,
        ogretmenKodu: teacher.ogretmenKodu,
        okul: teacher.okul,
      },
    };
  }

  async getMyTeachers(studentId: string) {
    const relations = await this.prisma.teacherStudent.findMany({
      where: { studentId },
      include: { teacher: { select: TEACHER_SELECT } },
      orderBy: { createdAt: 'desc' },
    });

    return relations.map((r) => ({
      relationId: r.id,
      connectedAt: r.createdAt,
      ...r.teacher,
    }));
  }

  async removeTeacher(studentId: string, teacherId: string) {
    const relation = await this.prisma.teacherStudent.findUnique({
      where: { teacherId_studentId: { teacherId, studentId } },
    });

    if (!relation) {
      throw new NotFoundException('Bu öğretmenle bağlantınız bulunamadı');
    }

    await this.prisma.teacherStudent.delete({ where: { id: relation.id } });
    this.logger.log(`Student ${studentId} removed teacher ${teacherId}`);

    return { message: 'Öğretmen bağlantısı kaldırıldı' };
  }

  // ─── Teacher actions ───────────────────────────────────────────────────

  async getMyStudents(teacherId: string, query: StudentQueryDto) {
    const { search, page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.TeacherStudentWhereInput = { teacherId };
    if (search) {
      where.student = {
        OR: [
          { adSoyad: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      };
    }

    const [relations, total] = await Promise.all([
      this.prisma.teacherStudent.findMany({
        where,
        include: { student: { select: STUDENT_SELECT } },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.teacherStudent.count({ where }),
    ]);

    const data = relations.map((r) => ({
      relationId: r.id,
      connectedAt: r.createdAt,
      ...r.student,
    }));

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getStudentDetail(teacherId: string, studentId: string) {
    const relation = await this.prisma.teacherStudent.findUnique({
      where: { teacherId_studentId: { teacherId, studentId } },
    });

    if (!relation) {
      throw new ForbiddenException('Bu öğrenci sizinle bağlantılı değil');
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

    return {
      ...student,
      connectedAt: relation.createdAt,
    };
  }

  async removeStudent(teacherId: string, studentId: string) {
    const relation = await this.prisma.teacherStudent.findUnique({
      where: { teacherId_studentId: { teacherId, studentId } },
    });

    if (!relation) {
      throw new NotFoundException('Bu öğrenciyle bağlantınız bulunamadı');
    }

    await this.prisma.teacherStudent.delete({ where: { id: relation.id } });
    this.logger.log(`Teacher ${teacherId} removed student ${studentId}`);

    return { message: 'Öğrenci bağlantısı kaldırıldı' };
  }
}
