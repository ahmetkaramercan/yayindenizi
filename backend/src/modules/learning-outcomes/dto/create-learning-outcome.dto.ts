import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateLearningOutcomeDto {
  @ApiProperty({ example: '21.5.1' })
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({ example: 'Paragrafta Ana Düşünce (Ana Fikir)' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ example: 'Paragrafın ana fikrini belirleme' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 'Paragraf Anlam' })
  @IsString()
  @IsNotEmpty()
  category: string;

  @ApiPropertyOptional({ example: '550e8400-e29b-41d4-a716-446655440000' })
  @IsOptional()
  @IsUUID()
  bookId?: string;
}
