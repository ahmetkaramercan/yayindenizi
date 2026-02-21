import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';
import { SubmitAnswerDto } from './dto';

@Injectable()
export class AnswersService {
  private readonly logger = new Logger(AnswersService.name);

  constructor(private prisma: PrismaService) {}

  async submit(userId: string, dto: SubmitAnswerDto) {
    const question = await this.prisma.question.findUnique({
      where: { id: dto.questionId },
      select: { id: true, correctAnswerIndex: true, testId: true },
    });
    if (!question) throw new NotFoundException('Soru bulunamadı');

    const existing = await this.prisma.studentAnswer.findUnique({
      where: { userId_questionId: { userId, questionId: dto.questionId } },
    });
    if (existing) {
      throw new ConflictException('Bu soruyu zaten cevapladınız.');
    }

    const isCorrect = dto.selectedIndex === question.correctAnswerIndex;

    const answer = await this.prisma.studentAnswer.create({
      data: {
        userId,
        questionId: dto.questionId,
        selectedIndex: dto.selectedIndex,
        isCorrect,
      },
    });

    this.logger.log(
      `Student ${userId} answered question ${dto.questionId}: ${isCorrect ? 'correct' : 'wrong'}`,
    );

    return {
      id: answer.id,
      questionId: answer.questionId,
      selectedIndex: answer.selectedIndex,
      correctAnswerIndex: question.correctAnswerIndex,
      isCorrect,
    };
  }

  async findByUser(userId: string, questionId?: string) {
    return this.prisma.studentAnswer.findMany({
      where: {
        userId,
        ...(questionId ? { questionId } : {}),
      },
      include: {
        question: {
          select: {
            id: true,
            correctAnswerIndex: true,
            testId: true,
            learningOutcomeId: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }
}
