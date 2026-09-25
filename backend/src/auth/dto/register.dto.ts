import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'jan_kowalski' })
  @IsString()
  @IsNotEmpty()
  login!: string;

  @ApiProperty({ example: 'jan@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email!: string;

  @ApiProperty({ example: 'haslo123!', minLength: 6 })
  @IsString()
  @MinLength(6)
  password!: string;
}
