import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@Injectable()
export class CategoryService {
  constructor(private prisma: PrismaService) {}

  async create(createCategoryDto: CreateCategoryDto, userId: number) {
    return this.prisma.category.create({
      data: {
        ...createCategoryDto,
        userId,
      },
    });
  }

  async findAll(userId: number) {
    return this.prisma.category.findMany({
      where: { userId },
    });
  }

  async findOne(id: number, userId: number) {
    const category = await this.prisma.category.findFirst({
      where: { id, userId },
    });

    if (!category) {
      throw new NotFoundException(`Kategoria o ID ${id} nie została znaleziona.`);
    }

    return category;
  }

  async update(id: number, updateCategoryDto: UpdateCategoryDto, userId: number) {
    // Sprawdzamy czy kategoria istnieje i należy do użytkownika
    await this.findOne(id, userId);

    return this.prisma.category.update({
      where: { id },
      data: updateCategoryDto,
    });
  }

  async remove(id: number, userId: number) {
    // Sprawdzamy czy kategoria istnieje i należy do użytkownika
    await this.findOne(id, userId);

    return this.prisma.category.delete({
      where: { id },
    });
  }
}