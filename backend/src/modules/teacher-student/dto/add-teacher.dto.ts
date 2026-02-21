import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class AddTeacherDto {
  @IsString()
  @IsNotEmpty({ message: 'Öğretmen kodu boş bırakılamaz' })
  @Length(8, 8, { message: 'Öğretmen kodu 8 karakter olmalıdır' })
  @Matches(/^[A-Z0-9]+$/, { message: 'Öğretmen kodu yalnızca büyük harf ve rakam içermelidir' })
  ogretmenKodu: string;
}
