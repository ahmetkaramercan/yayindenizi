import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

export class CreateStudentDto {
  @IsEmail({}, { message: 'Geçerli bir e-posta adresi giriniz' })
  email: string;

  @IsString()
  @MinLength(6, { message: 'Şifre en az 6 karakter olmalıdır' })
  @MaxLength(64, { message: 'Şifre en fazla 64 karakter olmalıdır' })
  @Matches(/^(?=.*[a-zA-Z])(?=.*\d).+$/, {
    message: 'Şifre en az bir harf ve bir rakam içermelidir',
  })
  password: string;

  @IsString()
  @IsNotEmpty({ message: 'Ad soyad boş bırakılamaz' })
  @MinLength(3, { message: 'Ad soyad en az 3 karakter olmalıdır' })
  @MaxLength(100)
  adSoyad: string;

  @IsString()
  @IsNotEmpty({ message: 'İl seçimi zorunludur' })
  cityId: string;

  @IsString()
  @IsNotEmpty({ message: 'İlçe seçimi zorunludur' })
  districtId: string;
}
