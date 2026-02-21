import { IsInt, IsUUID, Max, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SubmitAnswerDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  @IsUUID()
  questionId: string;

  @ApiProperty({ example: 1, minimum: 0, maximum: 4, description: '0=A, 1=B, 2=C, 3=D, 4=E' })
  @IsInt()
  @Min(0)
  @Max(4)
  selectedIndex: number;
}
