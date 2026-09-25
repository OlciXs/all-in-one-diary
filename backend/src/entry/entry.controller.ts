import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
  ParseIntPipe,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { EntryService } from './entry.service';
import { CreateEntryDto } from './dto/create-entry.dto';
import { UpdateEntryDto } from './dto/update-entry.dto';
import { ApiBearerAuth, ApiTags, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';

@ApiTags('entries')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('entries')
export class EntryController {
  constructor(private readonly entryService: EntryService) {}

  @Post()
  @UseInterceptors(FileInterceptor('photo')) // Używamy domyślnej pamięci RAM (MemoryStorage)
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        content: { type: 'string' },
        categoryId: { type: 'number' },
        startDate: { type: 'string', format: 'date-time' },
        endDate: { type: 'string', format: 'date-time' },
        isAllDay: { type: 'boolean' },
        photo: {
          type: 'string',
          format: 'binary',
          description: 'Zdjęcie wpisu',
        },
      },
      required: ['title', 'content', 'categoryId'],
    },
  })
  create(
    @Body() createEntryDto: CreateEntryDto,
    @UploadedFile() file: Express.Multer.File,
    @Req() req,
  ) {
    return this.entryService.create(createEntryDto, file, req.user.userId);
  }

  @Get()
  findAll(@Req() req) {
    return this.entryService.findAll(req.user.userId);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @Req() req) {
    return this.entryService.findOne(id, req.user.userId);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateEntryDto: UpdateEntryDto,
    @Req() req,
  ) {
    return this.entryService.update(id, updateEntryDto, req.user.userId);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req) {
    return this.entryService.remove(id, req.user.userId);
  }
}
