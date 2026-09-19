import { IsNotEmpty, IsString, IsBoolean, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({ example: 'Kwiatki' })
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiProperty({ example: '#4CAF50', required: false })
  @IsString()
  @IsOptional()
  color?: string;

  @ApiProperty({ example: true, required: false })
  @IsBoolean()
  @IsOptional()
  hasContent?: boolean;

  @ApiProperty({ example: true, required: false })
  @IsBoolean()
  @IsOptional()
  hasPhotos?: boolean;

  @ApiProperty({ example: true, required: false })
  @IsBoolean()
  @IsOptional()
  hasDate?: boolean;

  @ApiProperty({ example: true, required: false })
  @IsBoolean()
  @IsOptional()
  defaultToCurrentDate?: boolean;

  @ApiProperty({ example: false, required: false })
  @IsBoolean()
  @IsOptional()
  allowTimeRange?: boolean;
}