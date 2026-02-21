import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';
import { CreateSectionDto, UpdateSectionDto } from './dto';

@Injectable()
export class SectionsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateSectionDto) {
    const book = await this.prisma.book.findUnique({ where: { id: dto.bookId } });
    if (!book) throw new NotFoundException('Book not found');
    return this.prisma.section.create({ data: dto });
  }

  async findByBook(bookId: string) {
    return this.prisma.section.findMany({
      where: { bookId },
      include: { _count: { select: { tests: true } } },
      orderBy: { orderIndex: 'asc' },
    });
  }

  async findOne(id: string) {
    const section = await this.prisma.section.findUnique({
      where: { id },
      include: {
        book: true,
        tests: {
          include: { _count: { select: { questions: true } } },
          orderBy: { level: 'asc' },
        },
      },
    });
    if (!section) throw new NotFoundException('Section not found');
    return section;
  }

  async update(id: string, dto: UpdateSectionDto) {
    await this.findOne(id);
    return this.prisma.section.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.section.delete({ where: { id } });
  }
}
