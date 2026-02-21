import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  Logger,
} from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import { AppConfigService } from '@/config';

@Injectable()
export class PrismaService
  extends PrismaClient<Prisma.PrismaClientOptions, 'query' | 'info' | 'warn' | 'error'>
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor(private appConfig: AppConfigService) {
    const isProduction = process.env.NODE_ENV === 'production';

    super({
      datasources: { db: { url: appConfig.databaseUrl } },
      log: isProduction
        ? [
            { emit: 'event', level: 'error' },
            { emit: 'event', level: 'warn' },
          ]
        : [
            { emit: 'event', level: 'query' },
            { emit: 'event', level: 'info' },
            { emit: 'event', level: 'warn' },
            { emit: 'event', level: 'error' },
          ],
    });

    this.$on('query', (e: Prisma.QueryEvent) => {
      this.logger.debug(`Query: ${e.query} — ${e.duration}ms`);
    });

    this.$on('info', (e: Prisma.LogEvent) => {
      this.logger.log(e.message);
    });

    this.$on('warn', (e: Prisma.LogEvent) => {
      this.logger.warn(e.message);
    });

    this.$on('error', (e: Prisma.LogEvent) => {
      this.logger.error(e.message);
    });
  }

  async onModuleInit() {
    await this.$connect();
    this.logger.log('Database connected');
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log('Database disconnected');
  }

  async healthCheck(): Promise<boolean> {
    try {
      await this.$queryRaw`SELECT 1`;
      return true;
    } catch {
      return false;
    }
  }

  async cleanDatabase() {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('cleanDatabase is not allowed in production');
    }

    const models = Reflect.ownKeys(this).filter(
      (key) => typeof key === 'string' && !key.startsWith('_') && !key.startsWith('$'),
    );

    return Promise.all(
      models.map((modelKey) => {
        const model = (this as Record<string | symbol, unknown>)[modelKey];
        if (model && typeof model === 'object' && 'deleteMany' in model) {
          return (model as { deleteMany: () => Promise<unknown> }).deleteMany();
        }
        return Promise.resolve();
      }),
    );
  }
}
