import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { UsersService } from './users.service';
import {
  CreateAdminDto,
  UpdateStudentDto,
  UpdateTeacherDto,
  ChangePasswordDto,
  UserQueryDto,
} from './dto';
import { CurrentUser, Roles } from '@/common/decorators';

@ApiTags('Users')
@ApiBearerAuth('access-token')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ─── Admin endpoints ──────────────────────────────────────────────────

  @Get()
  @Roles(Role.ADMIN)
  findAll(@Query() query: UserQueryDto) {
    return this.usersService.findAll(query);
  }

  @Post('admin')
  @Roles(Role.ADMIN)
  createAdmin(@Body() dto: CreateAdminDto) {
    return this.usersService.createAdmin(dto);
  }

  @Get(':id')
  @Roles(Role.ADMIN)
  findById(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.findById(id);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  deleteUser(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.deleteUser(id);
  }

  // ─── Common endpoints ─────────────────────────────────────────────────

  @Patch('password')
  changePassword(@CurrentUser('id') userId: string, @Body() dto: ChangePasswordDto) {
    return this.usersService.changePassword(userId, dto);
  }

  // ─── Student endpoints ────────────────────────────────────────────────

  @Get('student/me')
  @Roles(Role.STUDENT)
  getMyStudentProfile(@CurrentUser('id') userId: string) {
    return this.usersService.getStudent(userId);
  }

  @Patch('student/me')
  @Roles(Role.STUDENT)
  updateMyStudentProfile(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateStudentDto,
  ) {
    return this.usersService.updateStudent(userId, dto);
  }

  // ─── Teacher endpoints ────────────────────────────────────────────────

  @Get('teacher/me')
  @Roles(Role.TEACHER)
  getMyTeacherProfile(@CurrentUser('id') userId: string) {
    return this.usersService.getTeacher(userId);
  }

  @Patch('teacher/me')
  @Roles(Role.TEACHER)
  updateMyTeacherProfile(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateTeacherDto,
  ) {
    return this.usersService.updateTeacher(userId, dto);
  }
}
