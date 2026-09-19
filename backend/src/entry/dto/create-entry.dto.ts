import { Type } from 'class-transformer';
import { IsNotEmpty, IsString, IsInt, IsDate, IsBoolean, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateEntryDto {
  @ApiProperty({ example: 'Hibiskus' })
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({ example: 'Mega ładny był ten Hibiskus' })
  @IsString()
  @IsOptional()
  content?: string;

  @ApiProperty({ example: 1 })
  @Type(() => Number)
  @IsInt()
  @IsNotEmpty()
  categoryId!: number;

  @ApiProperty({ example: '2026-09-19T12:00:00.000Z', required: false })
  @Type(() => Date)
  @IsDate()
  @IsOptional()
  startDate?: Date;

  @ApiProperty({ example: '2026-09-19T15:00:00.000Z', required: false })
  @Type(() => Date)
  @IsDate()
  @IsOptional()
  endDate?: Date;

  @ApiProperty({ example: true, required: false })
  @IsBoolean()
  @IsOptional()
  isAllDay?: boolean;
}