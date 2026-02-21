import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { Role, Prisma } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '@/prisma/prisma.service';
import { generateTeacherCode } from '@/common/utils/generate-code';
import {
  CreateStudentDto,
  CreateTeacherDto,
  CreateAdminDto,
  UpdateStudentDto,
  UpdateTeacherDto,
  ChangePasswordDto,
  UserQueryDto,
} from './dto';

const BCRYPT_ROUNDS = 10;
const TEACHER_CODE_MAX_RETRIES = 5;

const USER_SAFE_SELECT = {
  id: true,
  email: true,
  role: true,
  adSoyad: true,
  il: true,
  ilce: true,
  okul: true,
  ogretmenKodu: true,
  createdAt: true,
  updatedAt: true,
} as const;

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(private prisma: PrismaService) {}

  // ─── Creation ──────────────────────────────────────────────────────────

  async createStudent(dto: CreateStudentDto) {
    await this.ensureEmailAvailable(dto.email);
    const hashedPassword = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        password: hashedPassword,
        role: Role.STUDENT,
        adSoyad: dto.adSoyad,
        il: dto.il,
        ilce: dto.ilce,
      },
      select: USER_SAFE_SELECT,
    });

    this.logger.log(`Student created: ${user.id}`);
    return user;
  }

  async createTeacher(dto: CreateTeacherDto) {
    await this.ensureEmailAvailable(dto.email);
    const hashedPassword = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const ogretmenKodu = await this.generateUniqueTeacherCode();

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        password: hashedPassword,
        role: Role.TEACHER,
        adSoyad: dto.adSoyad,
        il: dto.il,
        ilce: dto.ilce,
        okul: dto.okul,
        ogretmenKodu,
      },
      select: USER_SAFE_SELECT,
    });

    this.logger.log(`Teacher created: ${user.id} (code: ${ogretmenKodu})`);
    return user;
  }

  async createAdmin(dto: CreateAdminDto) {
    await this.ensureEmailAvailable(dto.email);
    const hashedPassword = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        password: hashedPassword,
        role: Role.ADMIN,
        adSoyad: dto.adSoyad,
      },
      select: USER_SAFE_SELECT,
    });

    this.logger.log(`Admin created: ${user.id}`);
    return user;
  }

  // ─── Admin queries ─────────────────────────────────────────────────────

  async findAll(query: UserQueryDto) {
    const { role, search, page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.UserWhereInput = {};
    if (role) where.role = role;
    if (search) {
      where.OR = [
        { adSoyad: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: USER_SAFE_SELECT,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ]);

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        ...USER_SAFE_SELECT,
        teacherOf: {
          include: { student: { select: { id: true, adSoyad: true, email: true } } },
        },
        studentOf: {
          include: { teacher: { select: { id: true, adSoyad: true, ogretmenKodu: true } } },
        },
      },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async deleteUser(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    await this.prisma.user.delete({ where: { id } });
    this.logger.warn(`User deleted: ${id} (${user.email})`);
    return { message: 'User deleted successfully' };
  }

  // ─── Password ──────────────────────────────────────────────────────────

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const isCurrentValid = await bcrypt.compare(dto.currentPassword, user.password);
    if (!isCurrentValid) {
      throw new BadRequestException('Mevcut şifre hatalı');
    }

    const hashedPassword = await bcrypt.hash(dto.newPassword, BCRYPT_ROUNDS);
    await this.prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return { message: 'Password changed successfully' };
  }

  /**
   * Validates password against stored hash.
   * Used by AuthService during login.
   */
  async validatePassword(email: string): Promise<{ id: string; email: string; role: Role; adSoyad: string; password: string } | null> {
    return this.prisma.user.findUnique({
      where: { email },
      select: { id: true, email: true, role: true, adSoyad: true, password: true },
    });
  }

  // ─── Student profile ──────────────────────────────────────────────────

  async getStudent(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId, role: Role.STUDENT },
      select: {
        ...USER_SAFE_SELECT,
        studentOf: {
          include: { teacher: { select: { id: true, adSoyad: true, ogretmenKodu: true } } },
        },
      },
    });
    if (!user) throw new NotFoundException('Student not found');
    return user;
  }

  async updateStudent(userId: string, dto: UpdateStudentDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: dto,
      select: USER_SAFE_SELECT,
    });
  }

  // ─── Teacher profile ──────────────────────────────────────────────────

  async getTeacher(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId, role: Role.TEACHER },
      select: {
        ...USER_SAFE_SELECT,
        teacherOf: {
          include: { student: { select: { id: true, adSoyad: true, email: true } } },
        },
      },
    });
    if (!user) throw new NotFoundException('Teacher not found');
    return user;
  }

  async updateTeacher(userId: string, dto: UpdateTeacherDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: dto,
      select: USER_SAFE_SELECT,
    });
  }

  // ─── Private helpers ───────────────────────────────────────────────────

  private async ensureEmailAvailable(email: string) {
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new ConflictException('Bu e-posta adresi zaten kayıtlı');
    }
  }

  /**
   * Generates a unique 8-char teacher code, retrying on collision.
   */
  private async generateUniqueTeacherCode(): Promise<string> {
    for (let attempt = 0; attempt < TEACHER_CODE_MAX_RETRIES; attempt++) {
      const code = generateTeacherCode(8);
      const existing = await this.prisma.user.findUnique({
        where: { ogretmenKodu: code },
      });
      if (!existing) return code;
      this.logger.warn(`Teacher code collision on attempt ${attempt + 1}: ${code}`);
    }
    throw new ConflictException('Failed to generate unique teacher code, please try again');
  }
}
