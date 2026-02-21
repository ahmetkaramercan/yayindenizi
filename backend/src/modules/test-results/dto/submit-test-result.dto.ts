import { IsArray, IsInt, IsOptional, IsUUID, Max, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SubmitAnswerDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  @IsUUID()
  questionId: string;

  @ApiPropertyOptional({ example: 1, description: '0=A, 1=B, 2=C, 3=D, 4=E, null=boş' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(4)
  selectedIndex?: number | null;
}

export class SubmitTestResultDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  @IsUUID()
  testId: string;

  @ApiProperty({ example: 300, description: 'Toplam süre (saniye)' })
  @IsInt()
  @Min(0)
  totalTime: number;

  @ApiProperty({ type: [SubmitAnswerDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SubmitAnswerDto)
  answers: SubmitAnswerDto[];
}
