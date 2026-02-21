import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
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

  @Get('my/full')
  @Roles(Role.STUDENT)
  getMyFullAnalysis(@CurrentUser('id') userId: string) {
    return this.analyticsService.getStudentFullAnalysis(userId);
  }

  // ─── Teacher views of student analytics ─────────────────────────────

  @Get('student/:studentId/overview')
  @Roles(Role.TEACHER, Role.ADMIN)
  getStudentOverview(@Param('studentId') studentId: string) {
    return this.analyticsService.getStudentOverview(studentId);
  }

  @Get('student/:studentId/sections')
  @Roles(Role.TEACHER, Role.ADMIN)
  getStudentSectionStats(@Param('studentId') studentId: string) {
    return this.analyticsService.getStudentSectionStats(studentId);
  }

  @Get('student/:studentId/learning-outcomes')
  @Roles(Role.TEACHER, Role.ADMIN)
  getStudentLearningOutcomeStats(@Param('studentId') studentId: string) {
    return this.analyticsService.getStudentLearningOutcomeStats(studentId);
  }

  @Get('student/:studentId/full')
  @Roles(Role.TEACHER, Role.ADMIN)
  getStudentFullAnalysis(@Param('studentId') studentId: string) {
    return this.analyticsService.getStudentFullAnalysis(studentId);
  }

  // ─── Test result analytics ──────────────────────────────────────────

  @Get('result/:resultId')
  getTestAnalysis(@Param('resultId') resultId: string) {
    return this.analyticsService.getTestAnalysis(resultId);
  }
}
