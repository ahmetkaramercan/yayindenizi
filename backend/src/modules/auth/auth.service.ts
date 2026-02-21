import {
  Injectable,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { AppConfigService } from '@/config';
import { UsersService } from '@/modules/users/users.service';
import { CreateStudentDto, CreateTeacherDto } from '@/modules/users/dto';
import { LoginDto } from './dto';
import { AuthUser, JwtPayload } from './strategies/jwt.strategy';

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    role: Role;
    adSoyad: string;
    ogretmenKodu?: string | null;
  };
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private appConfig: AppConfigService,
  ) {}

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.usersService.validatePassword(dto.email);
    if (!user) {
      throw new UnauthorizedException('Geçersiz e-posta veya şifre');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Geçersiz e-posta veya şifre');
    }

    const tokens = await this.generateTokenPair(user.id, user.email, user.role);
    this.logger.log(`Login: ${user.email} (${user.role})`);

    return {
      ...tokens,
      user: { id: user.id, email: user.email, role: user.role, adSoyad: user.adSoyad },
    };
  }

  async registerStudent(dto: CreateStudentDto): Promise<AuthResponse> {
    const user = await this.usersService.createStudent(dto);
    const tokens = await this.generateTokenPair(user.id, user.email, user.role);
    this.logger.log(`Student registered: ${user.email}`);

    return {
      ...tokens,
      user: { id: user.id, email: user.email, role: user.role, adSoyad: user.adSoyad },
    };
  }

  async registerTeacher(dto: CreateTeacherDto): Promise<AuthResponse> {
    const user = await this.usersService.createTeacher(dto);
    const tokens = await this.generateTokenPair(user.id, user.email, user.role);
    this.logger.log(`Teacher registered: ${user.email} (code: ${user.ogretmenKodu})`);

    return {
      ...tokens,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        adSoyad: user.adSoyad,
        ogretmenKodu: user.ogretmenKodu,
      },
    };
  }

  async refreshTokens(user: AuthUser & { refreshToken: string }): Promise<Omit<AuthResponse, 'user'>> {
    const tokens = await this.generateTokenPair(user.id, user.email, user.role);
    this.logger.debug(`Token refreshed: ${user.email}`);
    return tokens;
  }

  async getProfile(userId: string) {
    return this.usersService.findById(userId);
  }

  // ─── Token generation ──────────────────────────────────────────────────

  private async generateTokenPair(
    userId: string,
    email: string,
    role: Role,
  ): Promise<{ accessToken: string; refreshToken: string }> {
    const payload: JwtPayload = { sub: userId, email, role };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, {
        secret: this.appConfig.jwtRefreshSecret,
        expiresIn: this.appConfig.jwtRefreshExpiresIn,
      }),
    ]);

    return { accessToken, refreshToken };
  }
}
