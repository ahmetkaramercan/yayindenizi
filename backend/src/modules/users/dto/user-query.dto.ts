import { IsOptional, IsEnum, IsInt, Min, Max, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { Role } from '@prisma/client';

export class UserQueryDto {
  @IsOptional()
  @IsEnum(Role, { message: 'Geçerli bir rol seçiniz (STUDENT, TEACHER, ADMIN)' })
  role?: Role;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
