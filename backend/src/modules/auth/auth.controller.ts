import {
  Controller,
  Post,
  Body,
  Get,
  Req,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { Request } from 'express';
import { AuthService } from './auth.service';
import { LoginDto, RefreshTokenDto } from './dto';
import { CreateStudentDto, CreateTeacherDto } from '@/modules/users/dto';
import { Public, CurrentUser } from '@/common/decorators';
import { JwtRefreshGuard } from './guards/jwt-refresh.guard';
import { AuthUser } from './strategies/jwt.strategy';

@ApiTags('Auth')
@ApiBearerAuth('access-token')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Public()
  @Post('register/student')
  registerStudent(@Body() dto: CreateStudentDto) {
    return this.authService.registerStudent(dto);
  }

  @Public()
  @Post('register/teacher')
  registerTeacher(@Body() dto: CreateTeacherDto) {
    return this.authService.registerTeacher(dto);
  }

  @Public()
  @UseGuards(JwtRefreshGuard)
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refresh(
    @CurrentUser() user: AuthUser & { refreshToken: string },
    @Body() _dto: RefreshTokenDto,
  ) {
    return this.authService.refreshTokens(user);
  }

  @Get('profile')
  getProfile(@CurrentUser('id') userId: string) {
    return this.authService.getProfile(userId);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  logout() {
    return { message: 'Logged out successfully' };
  }

  @Public()
  @Get('debug-headers')
  @ApiOperation({ summary: 'Debug: gelen headerları göster' })
  debugHeaders(@Req() req: Request) {
    const authHeader = req.headers['authorization'];
    return {
      hasAuthHeader: !!authHeader,
      authHeaderPrefix: authHeader ? authHeader.substring(0, 20) + '...' : null,
      allHeaders: Object.keys(req.headers),
    };
  }
}
