import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { TestResultsService } from './test-results.service';
import { SubmitTestResultDto } from './dto';
import { CurrentUser, Roles } from '@/common/decorators';

@ApiTags('Results')
@ApiBearerAuth('access-token')
@Controller('results')
export class TestResultsController {
  constructor(private readonly testResultsService: TestResultsService) {}

  @Post()
  @Roles(Role.STUDENT)
  @ApiOperation({ summary: 'Test sonucu gönder (optik form)' })
  submit(@CurrentUser('id') userId: string, @Body() dto: SubmitTestResultDto) {
    return this.testResultsService.submit(userId, dto);
  }

  @Get('my')
  @Roles(Role.STUDENT)
  @ApiOperation({ summary: 'Kendi sonuçlarımı getir' })
  @ApiQuery({ name: 'testId', required: false })
  findMyResults(@CurrentUser('id') userId: string, @Query('testId') testId?: string) {
    return this.testResultsService.findByUser(userId, testId);
  }

  @Get('my/history')
  @Roles(Role.STUDENT)
  @ApiOperation({ summary: 'Test geçmişim' })
  getMyHistory(@CurrentUser('id') userId: string) {
    return this.testResultsService.getUserHistory(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Sonuç detayı' })
  findOne(@Param('id') id: string) {
    return this.testResultsService.findOne(id);
  }

  @Get('student/:studentId')
  @Roles(Role.TEACHER, Role.ADMIN)
  @ApiOperation({ summary: 'Öğrencinin sonuçlarını getir (Öğretmen/Admin)' })
  @ApiQuery({ name: 'testId', required: false })
  findByStudent(@Param('studentId') studentId: string, @Query('testId') testId?: string) {
    return this.testResultsService.findByUser(studentId, testId);
  }
}
