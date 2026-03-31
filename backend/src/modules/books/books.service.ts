import { Injectable, NotFoundException } from '@nestjs/common';
import { BookCategory } from '@prisma/client';
import { PrismaService } from '@/prisma/prisma.service';
import { CreateBookDto, UpdateBookDto } from './dto';
import { PaginationDto } from '@/common/dto/pagination.dto';

@Injectable()
export class BooksService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateBookDto) {
    return this.prisma.book.create({ data: dto });
  }

  async findAll(pagination: PaginationDto, category?: BookCategory) {
    const where = category ? { category } : {};
    const [data, total] = await Promise.all([
      this.prisma.book.findMany({
        where,
        include: {
          sections: {
            include: { _count: { select: { tests: true } } },
            orderBy: { orderIndex: 'asc' },
          },
        },
        skip: pagination.skip,
        take: pagination.limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.book.count({ where }),
    ]);

    return { data, total, page: pagination.page, limit: pagination.limit };
  }

  async findOne(id: string) {
    const book = await this.prisma.book.findUnique({
      where: { id },
      include: {
        sections: {
          include: {
            tests: { select: { id: true, title: true, level: true } },
            _count: { select: { tests: true } },
          },
          orderBy: { orderIndex: 'asc' },
        },
      },
    });
    if (!book) throw new NotFoundException('Book not found');
    return book;
  }

  async getBookOutcomeVideos(id: string) {
    const outcomes = await this.prisma.learningOutcome.findMany({
      where: { bookId: id, videoUrl: { not: null } },
      select: { id: true, code: true, name: true, category: true, videoUrl: true },
      orderBy: { code: 'asc' },
    });
    return outcomes;
  }

  async update(id: string, dto: UpdateBookDto) {
    await this.findOne(id);
    return this.prisma.book.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.book.delete({ where: { id } });
  }
}
