import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEntryDto } from './dto/create-entry.dto';
import { UpdateEntryDto } from './dto/update-entry.dto';

@Injectable()
export class EntryService {
  constructor(private prisma: PrismaService) {}

  async create(createEntryDto: CreateEntryDto, userId: number) {
    const category = await this.prisma.category.findFirst({
      where: { id: createEntryDto.categoryId, userId },
    });

    if (!category) {
      throw new BadRequestException('Wybrana kategoria nie istnieje');
    }

    let startDate = createEntryDto.startDate;
    if (!startDate && category.defaultToCurrentDate) {
      startDate = new Date();
    }

    return this.prisma.entry.create({
      data: {
        title: createEntryDto.title,
        content: createEntryDto.content, // opcjonalne (string | undefined)
        startDate: startDate ?? new Date(),
        endDate: createEntryDto.endDate,
        isAllDay: createEntryDto.isAllDay ?? true,
        userId,
        categoryId: createEntryDto.categoryId,
      },
      include: {
        category: true,
      },
    });
  }

  async findAll(userId: number) {
    return this.prisma.entry.findMany({
      where: { userId },
      include: { category: true },
      orderBy: { startDate: 'desc' },
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
    await this.findOne(id, userId);

    if (updateEntryDto.categoryId) {
      const category = await this.prisma.category.findFirst({
        where: { id: updateEntryDto.categoryId, userId },
      });
      if (!category) {
        throw new BadRequestException('Wybrana kategoria nie istnieje');
      }
    }

    return this.prisma.entry.update({
      where: { id },
      data: updateEntryDto,
      include: { category: true },
    });
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    return this.prisma.entry.delete({
      where: { id },
    });
  }
}