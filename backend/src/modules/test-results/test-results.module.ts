import { Module } from '@nestjs/common';
import { TestResultsService } from './test-results.service';
import { TestResultsController } from './test-results.controller';
import { AnalyticsModule } from '../analytics/analytics.module';

@Module({
  imports: [AnalyticsModule],
  controllers: [TestResultsController],
  providers: [TestResultsService],
  exports: [TestResultsService],
})
export class TestResultsModule {}
