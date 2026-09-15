import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { EntryController } from './entry/entry.controller';

@Module({
  imports: [PrismaModule],
  controllers: [AppController, EntryController],
  providers: [AppService],
})
export class AppModule {}
