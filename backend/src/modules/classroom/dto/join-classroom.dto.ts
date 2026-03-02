import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class JoinClassroomDto {
  @ApiProperty({ example: 'AB3X7KP2', description: '8 haneli sınıf kodu' })
  @IsString()
  @IsNotEmpty()
  @Length(8, 8)
  @Matches(/^[A-Z0-9]+$/, { message: 'Kod sadece büyük harf ve rakamlardan oluşmalıdır' })
  code: string;
}
