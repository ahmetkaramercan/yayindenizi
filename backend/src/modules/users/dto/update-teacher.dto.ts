import { IsOptional, IsString, MinLength, MaxLength } from 'class-validator';

export class UpdateTeacherDto {
  @IsOptional()
  @IsString()
  @MinLength(3, { message: 'Ad soyad en az 3 karakter olmalıdır' })
  @MaxLength(100)
  adSoyad?: string;

  @IsOptional()
  @IsString()
  il?: string;

  @IsOptional()
  @IsString()
  ilce?: string;

  @IsOptional()
  @IsString()
  okul?: string;
}
