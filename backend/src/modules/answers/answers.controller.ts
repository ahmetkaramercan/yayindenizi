import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { AnswersService } from './answers.service';
import { SubmitAnswerDto } from './dto';
import { CurrentUser, Roles } from '@/common/decorators';

@ApiTags('Answers')
@ApiBearerAuth('access-token')
@Controller('answers')
export class AnswersController {
  constructor(private readonly answersService: AnswersService) {}

  @Post()
  @Roles(Role.STUDENT)
  @ApiOperation({ summary: 'Tek soru cevapla' })
  submit(@CurrentUser('id') userId: string, @Body() dto: SubmitAnswerDto) {
    return this.answersService.submit(userId, dto);
  }

  @Get('my')
  @Roles(Role.STUDENT)
  @ApiOperation({ summary: 'Kendi cevaplarımı getir' })
  @ApiQuery({ name: 'questionId', required: false })
  findMyAnswers(@CurrentUser('id') userId: string, @Query('questionId') questionId?: string) {
    return this.answersService.findByUser(userId, questionId);
  }
}
