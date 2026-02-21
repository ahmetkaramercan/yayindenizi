import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppConfig } from './configuration';

@Injectable()
export class AppConfigService {
  constructor(private configService: ConfigService<AppConfig, true>) {}

  get port(): number {
    return this.configService.get('port', { infer: true });
  }

  get corsOrigin(): string {
    return this.configService.get('corsOrigin', { infer: true });
  }

  get databaseUrl(): string {
    return this.configService.get('database', { infer: true }).url;
  }

  get jwtSecret(): string {
    return this.configService.get('jwt', { infer: true }).secret;
  }

  get jwtExpiresIn(): string {
    return this.configService.get('jwt', { infer: true }).expiresIn;
  }

  get jwtRefreshExpiresIn(): string {
    return this.configService.get('jwt', { infer: true }).refreshExpiresIn;
  }

  /**
   * Derived from JWT_SECRET to guarantee cryptographic separation
   * between access and refresh tokens without requiring an extra env var.
   */
  get jwtRefreshSecret(): string {
    return `${this.jwtSecret}:refresh`;
  }
}
