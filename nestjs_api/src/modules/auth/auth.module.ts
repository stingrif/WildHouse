// src/modules/auth/auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as admin from 'firebase-admin';

export interface JwtPayload {
  sub:   string;  // user id
  phone: string;
  iat?:  number;
  exp?:  number;
}

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  /**
   * Верифицирует Firebase ID Token (отправленный с мобильного после OTP)
   * и возвращает наши JWT access/refresh токены.
   */
  async firebaseLogin(idToken: string) {
    let decoded: admin.auth.DecodedIdToken;
    try {
      decoded = await admin.auth().verifyIdToken(idToken);
    } catch {
      throw new UnauthorizedException('Invalid Firebase token');
    }

    const userId = decoded.uid;
    const phone  = decoded.phone_number ?? '';

    // TODO: upsert user в БД
    // const user = await this.usersService.upsert({ firebaseUid: userId, phone });

    const payload: JwtPayload = { sub: userId, phone };

    return {
      accessToken:  this.jwtService.sign(payload, { expiresIn: '15m' }),
      refreshToken: this.jwtService.sign(payload, { expiresIn: '30d' }),
      userId,
      phone,
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify<JwtPayload>(refreshToken);
      const newPayload: JwtPayload = { sub: payload.sub, phone: payload.phone };
      return {
        accessToken: this.jwtService.sign(newPayload, { expiresIn: '15m' }),
      };
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }
}

// ─────────────────────────────────────────────────────────────
// src/modules/auth/auth.controller.ts
import { Body, Controller, Post } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

class FirebaseLoginDto {
  @ApiProperty({ description: 'Firebase ID Token from mobile app' })
  @IsString()
  idToken: string;
}

class RefreshDto {
  @ApiProperty()
  @IsString()
  refreshToken: string;
}

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('firebase')
  @ApiOperation({ summary: 'Login with Firebase OTP (phone auth)' })
  firebaseLogin(@Body() dto: FirebaseLoginDto) {
    return this.authService.firebaseLogin(dto.idToken);
  }

  @Post('refresh')
  @ApiOperation({ summary: 'Refresh access token' })
  refresh(@Body() dto: RefreshDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }
}

// ─────────────────────────────────────────────────────────────
// src/modules/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';

@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        secret: cfg.get<string>('JWT_SECRET'),
        signOptions: { issuer: 'wildhouse-api' },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService, JwtModule],
})
export class AuthModule {}
