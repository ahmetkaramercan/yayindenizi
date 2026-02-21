import { IsInt, IsNotEmpty, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateQuestionDto {
  @ApiPropertyOptional({ example: 'Soru metni (optik formda gösterilmez)' })
  @IsOptional()
  @IsString()
  text?: string;

  @ApiPropertyOptional({ example: 'A' })
  @IsOptional()
  @IsString()
  optionA?: string;

  @ApiPropertyOptional({ example: 'B' })
  @IsOptional()
  @IsString()
  optionB?: string;

  @ApiPropertyOptional({ example: 'C' })
  @IsOptional()
  @IsString()
  optionC?: string;

  @ApiPropertyOptional({ example: 'D' })
  @IsOptional()
  @IsString()
  optionD?: string;

  @ApiPropertyOptional({ example: 'E' })
  @IsOptional()
  @IsString()
  optionE?: string;

  @ApiProperty({ example: 1, minimum: 0, maximum: 4, description: '0=A, 1=B, 2=C, 3=D, 4=E' })
  @IsInt()
  @Min(0)
  @Max(4)
  correctAnswerIndex: number;

  @ApiPropertyOptional({ example: 'Doğru cevap B çünkü...' })
  @IsOptional()
  @IsString()
  explanation?: string;

  @ApiPropertyOptional({ example: 'https://example.com/video.mp4' })
  @IsOptional()
  @IsString()
  videoUrl?: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  orderIndex?: number;

  @ApiPropertyOptional({ example: '550e8400-e29b-41d4-a716-446655440000', description: 'Kazanım ID' })
  @IsOptional()
  @IsUUID()
  learningOutcomeId?: string;
}
