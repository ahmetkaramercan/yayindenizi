import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { LearningOutcomesService } from './learning-outcomes.service';
import { CreateLearningOutcomeDto } from './dto';
import { Roles } from '@/common/decorators';

@ApiTags('Learning Outcomes')
@ApiBearerAuth('access-token')
@Controller('learning-outcomes')
export class LearningOutcomesController {
  constructor(private readonly service: LearningOutcomesService) {}

  @Post()
  @Roles(Role.ADMIN)
  create(@Body() dto: CreateLearningOutcomeDto) {
    return this.service.create(dto);
  }

  @Get()
  findAll(@Query('category') category?: string) {
    return category ? this.service.findByCategory(category) : this.service.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  update(@Param('id') id: string, @Body() dto: Partial<CreateLearningOutcomeDto>) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
