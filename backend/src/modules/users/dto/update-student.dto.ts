import { IsOptional, IsString, MinLength, MaxLength } from 'class-validator';

export class UpdateStudentDto {
  @IsOptional()
  @IsString()
  @MinLength(3, { message: 'Ad soyad en az 3 karakter olmalıdır' })
  @MaxLength(100)
  adSoyad?: string;

  @IsOptional()
  @IsString()
  cityId?: string;

  @IsOptional()
  @IsString()
  districtId?: string;
}
