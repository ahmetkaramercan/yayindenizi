import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';
import { CreateLearningOutcomeDto } from './dto';

@Injectable()
export class LearningOutcomesService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateLearningOutcomeDto) {
    return this.prisma.learningOutcome.create({ data: dto });
  }

  async findAll() {
    return this.prisma.learningOutcome.findMany({
      orderBy: [{ category: 'asc' }, { name: 'asc' }],
    });
  }

  async findByCategory(category: string) {
    return this.prisma.learningOutcome.findMany({
      where: { category },
      orderBy: { name: 'asc' },
    });
  }

  async findOne(id: string) {
    const outcome = await this.prisma.learningOutcome.findUnique({ where: { id } });
    if (!outcome) throw new NotFoundException('Learning outcome not found');
    return outcome;
  }

  async update(id: string, dto: Partial<CreateLearningOutcomeDto>) {
    await this.findOne(id);
    return this.prisma.learningOutcome.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.learningOutcome.delete({ where: { id } });
  }
}
