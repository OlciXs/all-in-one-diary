import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEntryDto } from './dto/create-entry.dto';
import { UpdateEntryDto } from './dto/update-entry.dto';
import sharp from 'sharp';
import * as path from 'path';
import * as fs from 'fs/promises';

@Injectable()
export class EntryService {
  constructor(private prisma: PrismaService) {}

  async create(
    createEntryDto: CreateEntryDto,
    file: Express.Multer.File | undefined,
    userId: number,
  ) {
    const category = await this.prisma.category.findFirst({
      where: { id: Number(createEntryDto.categoryId), userId },
    });

    if (!category) {
      throw new BadRequestException('Wybrana kategoria nie istnieje');
    }

    let photoUrl: string | undefined = undefined;
    let thumbnailUrl: string | undefined = undefined;

    if (file && file.buffer) {
      const uploadDir = path.join(process.cwd(), 'uploads');
      const photosDir = path.join(uploadDir, 'photos');
      const thumbsDir = path.join(uploadDir, 'thumbnails');

      await fs.mkdir(photosDir, { recursive: true });
      await fs.mkdir(thumbsDir, { recursive: true });

      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
      const filename = `${uniqueSuffix}-${file.originalname}`;
      
      const originalPath = path.join(photosDir, filename);
      const thumbFilename = `thumb-${filename}`;
      const thumbPath = path.join(thumbsDir, thumbFilename);

      await fs.writeFile(originalPath, file.buffer);

      await sharp(file.buffer)
        .resize(200, 200, { fit: 'cover' })
        .toFile(thumbPath);


      photoUrl = `uploads/photos/${filename}`;
      thumbnailUrl = `uploads/thumbnails/${thumbFilename}`;
    }

    let startDate = createEntryDto.startDate ? new Date(createEntryDto.startDate) : undefined;
    if (!startDate && category.defaultToCurrentDate) {
      startDate = new Date();
    }

    return this.prisma.entry.create({
      data: {
        title: createEntryDto.title,
        content: createEntryDto.content,
        startDate: startDate ?? new Date(),
        endDate: createEntryDto.endDate ? new Date(createEntryDto.endDate) : null,
        isAllDay: String(createEntryDto.isAllDay) === 'true' || createEntryDto.isAllDay === true,
        photoUrl,
        thumbnailUrl,
        userId,
        categoryId: Number(createEntryDto.categoryId),
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
        where: { id: Number(updateEntryDto.categoryId), userId },
      });
      if (!category) {
        throw new BadRequestException('Wybrana kategoria nie istnieje');
      }
    }

    return this.prisma.entry.update({
      where: { id },
      data: {
        ...updateEntryDto,
        categoryId: updateEntryDto.categoryId ? Number(updateEntryDto.categoryId) : undefined,
      },
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