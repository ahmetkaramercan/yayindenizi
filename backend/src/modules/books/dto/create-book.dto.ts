import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { BookCategory } from '@prisma/client';

export class CreateBookDto {
  @ApiProperty({ example: 'Paragraf Koçu' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({ example: 'TYT Paragraf çalışma kitabı' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 'https://example.com/image.jpg' })
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiProperty({ enum: BookCategory, example: 'PARAGRAF' })
  @IsEnum(BookCategory)
  category: BookCategory;
}
