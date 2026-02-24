import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role, BookCategory } from '@prisma/client';
import { BooksService } from './books.service';
import { CreateBookDto, UpdateBookDto } from './dto';
import { Roles } from '@/common/decorators';
import { PaginationDto } from '@/common/dto/pagination.dto';

@ApiTags('Books')
@ApiBearerAuth('access-token')
@Controller('books')
export class BooksController {
  constructor(private readonly booksService: BooksService) {}

  @Post()
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Kitap oluştur (Admin)' })
  create(@Body() dto: CreateBookDto) {
    return this.booksService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Kitapları listele' })
  @ApiQuery({ name: 'category', enum: BookCategory, required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  findAll(@Query() pagination: PaginationDto, @Query('category') category?: BookCategory) {
    return this.booksService.findAll(pagination, category);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Kitap detayı (bölümler dahil)' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.booksService.findOne(id);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Kitap güncelle (Admin)' })
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateBookDto) {
    return this.booksService.update(id, dto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Kitap sil (Admin)' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.booksService.remove(id);
  }
}
