import { IsEmail, IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'jan@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email!: string;


  @ApiProperty({ example: 'haslo123!', minLength: 6 })
  @IsString()
  @IsNotEmpty()
  password!: string;
}