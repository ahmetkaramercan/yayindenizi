import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { TestsService } from './tests.service';
import { CreateTestDto, UpdateTestDto, CreateQuestionDto } from './dto';
import { Roles } from '@/common/decorators';

@ApiTags('Tests')
@ApiBearerAuth('access-token')
@Controller('tests')
export class TestsController {
  constructor(private readonly testsService: TestsService) {}

  @Post()
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Test oluştur (Admin)' })
  create(@Body() dto: CreateTestDto) {
    return this.testsService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Bölüme ait testleri listele' })
  @ApiQuery({ name: 'sectionId', required: true })
  findBySection(@Query('sectionId') sectionId: string) {
    return this.testsService.findBySection(sectionId);
  }

  @Get('level/:level')
  @ApiOperation({ summary: 'Seviyeye göre testleri listele' })
  findByLevel(@Param('level', ParseIntPipe) level: number) {
    return this.testsService.findByLevel(level);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Test detayı (sorular dahil)' })
  findOne(@Param('id') id: string) {
    return this.testsService.findOne(id);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Test güncelle (Admin)' })
  update(@Param('id') id: string, @Body() dto: UpdateTestDto) {
    return this.testsService.update(id, dto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Test sil (Admin)' })
  remove(@Param('id') id: string) {
    return this.testsService.remove(id);
  }

  @Post(':id/questions')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Teste soru ekle (Admin)' })
  addQuestion(@Param('id') testId: string, @Body() dto: CreateQuestionDto) {
    return this.testsService.addQuestion(testId, dto);
  }

  @Patch('questions/:questionId')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Soruyu güncelle (Admin)' })
  updateQuestion(@Param('questionId') questionId: string, @Body() dto: Partial<CreateQuestionDto>) {
    return this.testsService.updateQuestion(questionId, dto);
  }

  @Delete('questions/:questionId')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Soruyu sil (Admin)' })
  removeQuestion(@Param('questionId') questionId: string) {
    return this.testsService.removeQuestion(questionId);
  }
}
