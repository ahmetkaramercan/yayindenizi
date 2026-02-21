import { IsString, MinLength, MaxLength, Matches, IsNotEmpty } from 'class-validator';

export class ChangePasswordDto {
  @IsString()
  @IsNotEmpty({ message: 'Mevcut şifre boş bırakılamaz' })
  currentPassword: string;

  @IsString()
  @MinLength(6, { message: 'Yeni şifre en az 6 karakter olmalıdır' })
  @MaxLength(64, { message: 'Yeni şifre en fazla 64 karakter olmalıdır' })
  @Matches(/^(?=.*[a-zA-Z])(?=.*\d).+$/, {
    message: 'Yeni şifre en az bir harf ve bir rakam içermelidir',
  })
  newPassword: string;
}
