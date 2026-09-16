import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEntryDto } from './dto/create-entry.dto';
import { UpdateEntryDto } from './dto/update-entry.dto';

@Injectable()
export class EntryService {
  constructor(private prisma: PrismaService) {}

  async create(createEntryDto: CreateEntryDto, userId: number) {
    return this.prisma.entry.create({
      data: {
        ...createEntryDto,
        userId,
      },
    });
  }

  async findAll() {
    return this.prisma.entry.findMany({
      include: {
        category: true,
        user: true,
      },
      orderBy: {
        id: 'desc',
      },
    });
  }

  async findOne(id: number) {
    const entry = await this.prisma.entry.findUnique({
      where: { id },
      include: {
        category: true,
        user: true,
      },
    });

    if (!entry) {
      throw new NotFoundException(`Wpis o ID ${id} nie został znaleziony.`);
    }

    return entry;
  }

  async update(id: number, updateEntryDto: UpdateEntryDto) {
    await this.findOne(id);

    return this.prisma.entry.update({
      where: { id },
      data: updateEntryDto,
    });
  }

  async remove(id: number) {
    await this.findOne(id);

    return this.prisma.entry.delete({
      where: { id },
    });
  }
}