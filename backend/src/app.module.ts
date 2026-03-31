import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { CacheModule } from '@nestjs/cache-manager';
import { AppConfigModule } from './config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { BooksModule } from './modules/books/books.module';
import { SectionsModule } from './modules/sections/sections.module';
import { TestsModule } from './modules/tests/tests.module';
import { TestResultsModule } from './modules/test-results/test-results.module';
import { LearningOutcomesModule } from './modules/learning-outcomes/learning-outcomes.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { ClassroomModule } from './modules/classroom/classroom.module';
import { AnswersModule } from './modules/answers/answers.module';
import { CitiesModule } from './modules/cities/cities.module';
import { YoutubeModule } from './modules/youtube/youtube.module';
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from './common/guards/roles.guard';

@Module({
  imports: [
    CacheModule.register({ isGlobal: true, ttl: 300_000, max: 200 }),
    AppConfigModule,
    PrismaModule,
    AuthModule,
    UsersModule,
    BooksModule,
    SectionsModule,
    TestsModule,
    TestResultsModule,
    LearningOutcomesModule,
    AnalyticsModule,
    ClassroomModule,
    AnswersModule,
    CitiesModule,
    YoutubeModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
