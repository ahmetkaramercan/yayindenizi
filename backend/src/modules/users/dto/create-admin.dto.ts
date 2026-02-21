import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

export class CreateAdminDto {
  @IsEmail({}, { message: 'Geçerli bir e-posta adresi giriniz' })
  email: string;

  @IsString()
  @MinLength(8, { message: 'Admin şifresi en az 8 karakter olmalıdır' })
  @MaxLength(64, { message: 'Şifre en fazla 64 karakter olmalıdır' })
  @Matches(/^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*]).+$/, {
    message: 'Şifre en az bir harf, bir rakam ve bir özel karakter içermelidir',
  })
  password: string;

  @IsString()
  @IsNotEmpty({ message: 'Ad soyad boş bırakılamaz' })
  @MinLength(3, { message: 'Ad soyad en az 3 karakter olmalıdır' })
  @MaxLength(100)
  adSoyad: string;
}
