import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { CitiesService } from './cities.service';
import { Public } from '@/common/decorators';

@ApiTags('Cities')
@Controller('cities')
export class CitiesController {
  constructor(private readonly citiesService: CitiesService) {}

  @Get()
  @Public()
  @ApiOperation({ summary: 'İlleri listele (opsiyonel arama)' })
  @ApiQuery({ name: 'search', required: false })
  findAll(@Query('search') search?: string) {
    return this.citiesService.findAll(search);
  }

  @Get('districts')
  @Public()
  @ApiOperation({ summary: 'İlçeleri listele (cityId zorunlu)' })
  @ApiQuery({ name: 'cityId', required: true })
  @ApiQuery({ name: 'search', required: false })
  findDistricts(
    @Query('cityId') cityId: string,
    @Query('search') search?: string,
  ) {
    return this.citiesService.findDistricts(cityId, search);
  }
}
