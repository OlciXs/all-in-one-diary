import { IsNotEmpty, IsString, IsInt } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({example: 'Kwiatki'})
  @IsString()
  @IsNotEmpty()
  name!: string;
}