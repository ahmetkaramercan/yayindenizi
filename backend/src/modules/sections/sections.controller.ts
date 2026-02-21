import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { SectionsService } from './sections.service';
import { CreateSectionDto, UpdateSectionDto } from './dto';
import { Roles } from '@/common/decorators';

@ApiTags('Sections')
@ApiBearerAuth('access-token')
@Controller('sections')
export class SectionsController {
  constructor(private readonly sectionsService: SectionsService) {}

  @Post()
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Bölüm oluştur (Admin)' })
  create(@Body() dto: CreateSectionDto) {
    return this.sectionsService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Kitaba ait bölümleri listele' })
  @ApiQuery({ name: 'bookId', required: true })
  findByBook(@Query('bookId') bookId: string) {
    return this.sectionsService.findByBook(bookId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Bölüm detayı (testler dahil)' })
  findOne(@Param('id') id: string) {
    return this.sectionsService.findOne(id);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Bölüm güncelle (Admin)' })
  update(@Param('id') id: string, @Body() dto: UpdateSectionDto) {
    return this.sectionsService.update(id, dto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Bölüm sil (Admin)' })
  remove(@Param('id') id: string) {
    return this.sectionsService.remove(id);
  }
}
