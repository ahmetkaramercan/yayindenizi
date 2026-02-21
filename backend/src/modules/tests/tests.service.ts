import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';
import { CreateTestDto, UpdateTestDto, CreateQuestionDto } from './dto';

@Injectable()
export class TestsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateTestDto) {
    const section = await this.prisma.section.findUnique({ where: { id: dto.sectionId } });
    if (!section) throw new NotFoundException('Section not found');

    const { questions, ...testData } = dto;

    return this.prisma.test.create({
      data: {
        ...testData,
        questions: questions
          ? {
              create: questions.map((q, i) => ({
                ...q,
                orderIndex: q.orderIndex ?? i,
              })),
            }
          : undefined,
      },
      include: {
        questions: { orderBy: { orderIndex: 'asc' } },
      },
    });
  }

  async findBySection(sectionId: string) {
    return this.prisma.test.findMany({
      where: { sectionId },
      include: { _count: { select: { questions: true } } },
      orderBy: { level: 'asc' },
    });
  }

  async findByLevel(level: number) {
    return this.prisma.test.findMany({
      where: { level },
      include: {
        section: { include: { book: true } },
        _count: { select: { questions: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const test = await this.prisma.test.findUnique({
      where: { id },
      include: {
        section: { include: { book: true } },
        questions: {
          include: { learningOutcome: true },
          orderBy: { orderIndex: 'asc' },
        },
      },
    });
    if (!test) throw new NotFoundException('Test not found');
    return test;
  }

  async update(id: string, dto: UpdateTestDto) {
    await this.findOne(id);
    return this.prisma.test.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.test.delete({ where: { id } });
  }

  async addQuestion(testId: string, dto: CreateQuestionDto) {
    await this.findOne(testId);

    const maxOrder = await this.prisma.question.findFirst({
      where: { testId },
      orderBy: { orderIndex: 'desc' },
      select: { orderIndex: true },
    });

    return this.prisma.question.create({
      data: {
        ...dto,
        testId,
        orderIndex: dto.orderIndex ?? (maxOrder ? maxOrder.orderIndex + 1 : 0),
      },
      include: { learningOutcome: true },
    });
  }

  async updateQuestion(questionId: string, dto: Partial<CreateQuestionDto>) {
    const question = await this.prisma.question.findUnique({ where: { id: questionId } });
    if (!question) throw new NotFoundException('Question not found');

    return this.prisma.question.update({
      where: { id: questionId },
      data: dto,
      include: { learningOutcome: true },
    });
  }

  async removeQuestion(questionId: string) {
    const question = await this.prisma.question.findUnique({ where: { id: questionId } });
    if (!question) throw new NotFoundException('Question not found');
    return this.prisma.question.delete({ where: { id: questionId } });
  }
}
