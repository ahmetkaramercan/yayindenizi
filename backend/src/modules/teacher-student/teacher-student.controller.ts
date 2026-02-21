import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { TeacherStudentService } from './teacher-student.service';
import { AddTeacherDto, StudentQueryDto } from './dto';
import { CurrentUser, Roles } from '@/common/decorators';

@ApiTags('Relations')
@ApiBearerAuth('access-token')
@Controller('relations')
export class TeacherStudentController {
  constructor(private readonly service: TeacherStudentService) {}

  // ─── Student perspective ───────────────────────────────────────────────

  @Post('teachers')
  @Roles(Role.STUDENT)
  addTeacher(@CurrentUser('id') studentId: string, @Body() dto: AddTeacherDto) {
    return this.service.addTeacher(studentId, dto);
  }

  @Get('my-teachers')
  @Roles(Role.STUDENT)
  getMyTeachers(@CurrentUser('id') studentId: string) {
    return this.service.getMyTeachers(studentId);
  }

  @Delete('teachers/:teacherId')
  @Roles(Role.STUDENT)
  removeTeacher(
    @CurrentUser('id') studentId: string,
    @Param('teacherId', ParseUUIDPipe) teacherId: string,
  ) {
    return this.service.removeTeacher(studentId, teacherId);
  }

  // ─── Teacher perspective ───────────────────────────────────────────────

  @Get('my-students')
  @Roles(Role.TEACHER)
  getMyStudents(
    @CurrentUser('id') teacherId: string,
    @Query() query: StudentQueryDto,
  ) {
    return this.service.getMyStudents(teacherId, query);
  }

  @Get('students/:studentId')
  @Roles(Role.TEACHER)
  getStudentDetail(
    @CurrentUser('id') teacherId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    return this.service.getStudentDetail(teacherId, studentId);
  }

  @Delete('students/:studentId')
  @Roles(Role.TEACHER)
  removeStudent(
    @CurrentUser('id') teacherId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    return this.service.removeStudent(teacherId, studentId);
  }
}
