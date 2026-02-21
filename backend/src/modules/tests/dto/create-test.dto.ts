import {
  IsArray,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CreateQuestionDto } from './create-question.dto';

export class CreateTestDto {
  @ApiProperty({ example: 'Ana Fikir Testi - Seviye 1' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({ example: 'Paragrafın ana fikrini bulma testi' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 1, minimum: 1, maximum: 8 })
  @IsInt()
  @Min(1)
  @Max(8)
  level: number;

  @ApiPropertyOptional({ example: 600, description: 'Süre (saniye)' })
  @IsOptional()
  @IsInt()
  @Min(0)
  timeLimit?: number;

  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  @IsUUID()
  sectionId: string;

  @ApiPropertyOptional({ type: [CreateQuestionDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionDto)
  questions?: CreateQuestionDto[];
}
