import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { YoutubeService } from './youtube.service';
import { Public } from '@/common/decorators';

@ApiTags('YouTube')
@Controller('youtube')
export class YoutubeController {
  constructor(private readonly youtubeService: YoutubeService) {}

  @Get('shorts')
  @Public()
  @ApiOperation({ summary: 'Rehberlik YouTube Shorts listesi' })
  getShorts() {
    return this.youtubeService.getShorts();
  }
}
