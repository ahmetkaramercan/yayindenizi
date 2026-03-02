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
import { ClassroomService } from './classroom.service';
import {
  CreateClassroomDto,
  UpdateClassroomDto,
  JoinClassroomDto,
  ClassroomQueryDto,
} from './dto';
import { CurrentUser, Roles } from '@/common/decorators';

@ApiTags('Classrooms')
@ApiBearerAuth('access-token')
@Controller('classrooms')
export class ClassroomController {
  constructor(private readonly service: ClassroomService) {}

  // ─── Student endpoints ─────────────────────────────────────────────────
  // NOTE: Literal routes must come before parameterized routes to avoid collisions.

  @Post('join')
  @Roles(Role.STUDENT)
  joinClassroom(
    @CurrentUser('id') studentId: string,
    @Body() dto: JoinClassroomDto,
  ) {
    return this.service.joinClassroom(studentId, dto);
  }

  @Get('my-classrooms')
  @Roles(Role.STUDENT)
  getStudentClassrooms(@CurrentUser('id') studentId: string) {
    return this.service.getStudentClassrooms(studentId);
  }

  @Delete('my-classrooms/:classroomId')
  @Roles(Role.STUDENT)
  leaveClassroom(
    @CurrentUser('id') studentId: string,
    @Param('classroomId', ParseUUIDPipe) classroomId: string,
  ) {
    return this.service.leaveClassroom(studentId, classroomId);
  }

  // ─── Teacher endpoints ─────────────────────────────────────────────────

  @Post()
  @Roles(Role.TEACHER)
  createClassroom(
    @CurrentUser('id') teacherId: string,
    @Body() dto: CreateClassroomDto,
  ) {
    return this.service.createClassroom(teacherId, dto);
  }

  @Get()
  @Roles(Role.TEACHER)
  getMyClassrooms(@CurrentUser('id') teacherId: string) {
    return this.service.getMyClassrooms(teacherId);
  }

  @Get(':classroomId')
  @Roles(Role.TEACHER)
  getClassroomDetail(
    @CurrentUser('id') teacherId: string,
    @Param('classroomId', ParseUUIDPipe) classroomId: string,
    @Query() query: ClassroomQueryDto,
  ) {
    return this.service.getClassroomDetail(teacherId, classroomId, query);
  }

  @Patch(':classroomId')
  @Roles(Role.TEACHER)
  updateClassroom(
    @CurrentUser('id') teacherId: string,
    @Param('classroomId', ParseUUIDPipe) classroomId: string,
    @Body() dto: UpdateClassroomDto,
  ) {
    return this.service.updateClassroom(teacherId, classroomId, dto);
  }

  @Delete(':classroomId')
  @Roles(Role.TEACHER)
  deleteClassroom(
    @CurrentUser('id') teacherId: string,
    @Param('classroomId', ParseUUIDPipe) classroomId: string,
  ) {
    return this.service.deleteClassroom(teacherId, classroomId);
  }

  @Post(':classroomId/regenerate-code')
  @Roles(Role.TEACHER)
  regenerateCode(
    @CurrentUser('id') teacherId: string,
    @Param('classroomId', ParseUUIDPipe) classroomId: string,
  ) {
    return this.service.regenerateCode(teacherId, classroomId);
  }

  @Get(':classroomId/students/:studentId')
  @Roles(Role.TEACHER)
  getStudentInClassroom(
    @CurrentUser('id') teacherId: string,
    @Param('classroomId', ParseUUIDPipe) classroomId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    return this.service.getStudentInClassroom(teacherId, classroomId, studentId);
  }

  @Delete(':classroomId/students/:studentId')
  @Roles(Role.TEACHER)
  removeStudentFromClassroom(
    @CurrentUser('id') teacherId: string,
    @Param('classroomId', ParseUUIDPipe) classroomId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    return this.service.removeStudentFromClassroom(teacherId, classroomId, studentId);
  }
}
