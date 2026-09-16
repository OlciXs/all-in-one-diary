import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEntryDto } from './dto/create-entry.dto';
import { UpdateEntryDto } from './dto/update-entry.dto';

@Injectable()
export class EntryService {
  constructor(private prisma: PrismaService) {}

  async create(createEntryDto: CreateEntryDto, userId: number) {
    //Sprawdzamy, czy kategoria istnieje I należy do tego użytkownika
    const category = await this.prisma.category.findFirst({
      where: { id: createEntryDto.categoryId, userId },
    });

    if (!category) {
      throw new BadRequestException('Wybrana kategoria nie istnieje');
    }

    //Tworzymy wpis przypisany do usera
    return this.prisma.entry.create({
      data: {
        ...createEntryDto,
        userId,
      },
    });
  }

  async findAll(userId: number) {
    return this.prisma.entry.findMany({
      where: { userId },
      include: { category: true }, // Dołączamy informacje o kategorii
    });
  }

  async findOne(id: number, userId: number) {
    const entry = await this.prisma.entry.findFirst({
      where: { id, userId },
      include: { category: true },
    });
    if (!entry) {
      throw new NotFoundException('Wpis nie został znaleziony');
    }
    return entry;
  }

  async update(id: number, updateEntryDto: UpdateEntryDto, userId: number) {
    // Sprawdzamy, czy wpis w ogóle istnieje I czy należy do zalogowanego użytkownika
    await this.findOne(id, userId);

    // Jeśli użytkownik chce zmienić kategorię wpisu, sprawdzamy czy nowa kategoria należy do niego
    if (updateEntryDto.categoryId) {
      const category = await this.prisma.category.findFirst({
        where: { id: updateEntryDto.categoryId, userId },
      });
      if (!category) {
        throw new BadRequestException('Wybrana kategoria nie istnieje');
      }
    }

    //Wykonujemy bezpieczną aktualizację
    return this.prisma.entry.update({
      where: { id },
      data: updateEntryDto,
    });
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    return this.prisma.entry.delete({
      where: { id },
    });
  }
}