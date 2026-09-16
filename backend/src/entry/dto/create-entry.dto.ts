import { Type } from 'class-transformer';
import { IsNotEmpty, IsString, IsInt } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateEntryDto {
  @ApiProperty({example: 'Hibiskus'})
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({example: 'Mega ładny był ten Hibiskus'})
  @IsString()
  @IsNotEmpty()
  content!: string;

  @ApiProperty({example: 1})
  @Type(() => Number)
  @IsInt()
  @IsNotEmpty()
  categoryId!: number;
}