import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateLearningOutcomeDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsString()
  @IsNotEmpty()
  category: string;
}
