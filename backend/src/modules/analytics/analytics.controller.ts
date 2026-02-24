import {
  Controller,
  Get,
  Param,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { AnalyticsService } from './analytics.service';
import { CurrentUser, Roles } from '@/common/decorators';

@ApiTags('Analytics')
@ApiBearerAuth('access-token')
@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  // ─── Student self-analytics ─────────────────────────────────────────

  @Get('my/overview')
  @Roles(Role.STUDENT)
  getMyOverview(@CurrentUser('id') userId: string) {
    return this.analyticsService.getStudentOverview(userId);
  }

  @Get('my/sections')
  @Roles(Role.STUDENT)
  getMySectionStats(@CurrentUser('id') userId: string) {
    return this.analyticsService.getStudentSectionStats(userId);
  }

  @Get('my/learning-outcomes')
  @Roles(Role.STUDENT)
  getMyLearningOutcomeStats(@CurrentUser('id') userId: string) {
    return this.analyticsService.getStudentLearningOutcomeStats(userId);
  }

  @Get('my/learning-outcomes/categories')
  @Roles(Role.STUDENT)
  getMyOutcomesByCategory(@CurrentUser('id') userId: string) {
    return this.analyticsService.getStudentOutcomesByCategory(userId);
  }

  @Get('my/weak-outcomes')
  @Roles(Role.STUDENT)
  @ApiQuery({ name: 'threshold', required: false, type: Number })
  getMyWeakOutcomes(
    @CurrentUser('id') userId: string,
    @Query('threshold') threshold?: string,
  ) {
    return this.analyticsService.getStudentWeakOutcomes(
      userId,
      threshold ? Number(threshold) : undefined,
    );
  }

  @Get('my/progress')
  @Roles(Role.STUDENT)
  getMyProgress(@CurrentUser('id') userId: string) {
    return this.analyticsService.getStudentProgressOverTime(userId);
  }

  @Get('my/weak-sections')
  @Roles(Role.STUDENT)
  getMyWeakSections(@CurrentUser('id') userId: string) {
    return this.analyticsService.getStudentWeakSections(userId);
  }

  @Get('my/section/:sectionId')
  @Roles(Role.STUDENT)
  getMySectionAnalysis(
    @CurrentUser('id') userId: string,
    @Param('sectionId', ParseUUIDPipe) sectionId: string,
  ) {
    return this.analyticsService.getSectionAnalysis(userId, sectionId);
  }

  @Get('my/full')
  @Roles(Role.STUDENT)
  @ApiQuery({ name: 'bookId', required: false })
  getMyFullAnalysis(
    @CurrentUser('id') userId: string,
    @Query('bookId') bookId?: string,
  ) {
    return this.analyticsService.getStudentFullAnalysis(userId, bookId);
  }

  // ─── Teacher views of student analytics ─────────────────────────────

  @Get('student/:studentId/overview')
  @Roles(Role.TEACHER, Role.ADMIN)
  async getStudentOverview(
    @CurrentUser('id') teacherId: string,
    @CurrentUser('role') role: Role,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    if (role === Role.TEACHER) {
      await this.analyticsService.verifyTeacherAccess(teacherId, studentId);
    }
    return this.analyticsService.getStudentOverview(studentId);
  }

  @Get('student/:studentId/sections')
  @Roles(Role.TEACHER, Role.ADMIN)
  async getStudentSectionStats(
    @CurrentUser('id') teacherId: string,
    @CurrentUser('role') role: Role,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    if (role === Role.TEACHER) {
      await this.analyticsService.verifyTeacherAccess(teacherId, studentId);
    }
    return this.analyticsService.getStudentSectionStats(studentId);
  }

  @Get('student/:studentId/learning-outcomes')
  @Roles(Role.TEACHER, Role.ADMIN)
  async getStudentLearningOutcomeStats(
    @CurrentUser('id') teacherId: string,
    @CurrentUser('role') role: Role,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    if (role === Role.TEACHER) {
      await this.analyticsService.verifyTeacherAccess(teacherId, studentId);
    }
    return this.analyticsService.getStudentLearningOutcomeStats(studentId);
  }

  @Get('student/:studentId/learning-outcomes/categories')
  @Roles(Role.TEACHER, Role.ADMIN)
  async getStudentOutcomesByCategory(
    @CurrentUser('id') teacherId: string,
    @CurrentUser('role') role: Role,
    @Param('studentId', ParseUUIDPipe) studentId: string,
  ) {
    if (role === Role.TEACHER) {
      await this.analyticsService.verifyTeacherAccess(teacherId, studentId);
    }
    return this.analyticsService.getStudentOutcomesByCategory(studentId);
  }

  @Get('student/:studentId/weak-outcomes')
  @Roles(Role.TEACHER, Role.ADMIN)
  @ApiQuery({ name: 'threshold', required: false, type: Number })
  async getStudentWeakOutcomes(
    @CurrentUser('id') teacherId: string,
    @CurrentUser('role') role: Role,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @Query('threshold') threshold?: string,
  ) {
    if (role === Role.TEACHER) {
      await this.analyticsService.verifyTeacherAccess(teacherId, studentId);
    }
    return this.analyticsService.getStudentWeakOutcomes(
      studentId,
      threshold ? Number(threshold) : undefined,
    );
  }

  @Get('student/:studentId/full')
  @Roles(Role.TEACHER, Role.ADMIN)
  @ApiQuery({ name: 'bookId', required: false })
  async getStudentFullAnalysis(
    @CurrentUser('id') teacherId: string,
    @CurrentUser('role') role: Role,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @Query('bookId') bookId?: string,
  ) {
    if (role === Role.TEACHER) {
      await this.analyticsService.verifyTeacherAccess(teacherId, studentId);
    }
    return this.analyticsService.getStudentFullAnalysis(studentId, bookId);
  }

  // ─── Test result analytics ──────────────────────────────────────────

  @Get('result/:resultId')
  getTestAnalysis(@Param('resultId', ParseUUIDPipe) resultId: string) {
    return this.analyticsService.getTestAnalysis(resultId);
  }

  // ─── Admin: recalculate ─────────────────────────────────────────────

  @Get('admin/recalculate/:userId')
  @Roles(Role.ADMIN)
  recalculate(@Param('userId', ParseUUIDPipe) userId: string) {
    return this.analyticsService.recalculateOutcomeAnalytics(userId);
  }
}
