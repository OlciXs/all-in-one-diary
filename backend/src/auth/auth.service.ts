import {
  Injectable,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    //Sprawdzenie, czy email lub login są już zajęte
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: dto.email }, { login: dto.login }],
      },
    });

    if (existingUser) {
      throw new ConflictException('Użytkownik o podanym emailu lub loginie już istnieje.');
    }

    //Hashowanie hasła
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    //Zapis nowego użytkownika
    const user = await this.prisma.user.create({
      data: {
        login: dto.login,
        email: dto.email,
        password: hashedPassword,
      },
    });

    // Usuwamy password z odpowiedzi
    const { password, ...result } = user;
    return result;
  }

  async login(dto: LoginDto) {
    //Wyszukanie użytkownika
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Nieprawidłowy email lub hasło.');
    }

    //Weryfikacja hasła
    const isPasswordValid = await bcrypt.compare(dto.password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Nieprawidłowy email lub hasło.');
    }

    //Generowanie tokenu JWT
    const payload = { sub: user.id, email: user.email, login: user.login };
    
    return {
      access_token: await this.jwtService.signAsync(payload),
    };
  }
}