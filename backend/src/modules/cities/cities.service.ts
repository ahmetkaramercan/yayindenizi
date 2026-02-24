import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';

@Injectable()
export class CitiesService {
  constructor(private prisma: PrismaService) {}

  async findAll(search?: string) {
    const where = search
      ? { name: { contains: search, mode: 'insensitive' as const } }
      : {};

    return this.prisma.city.findMany({
      where,
      orderBy: { name: 'asc' },
      select: { id: true, name: true },
    });
  }

  async findDistricts(cityId: string, search?: string) {
    const where: { cityId: string; name?: { contains: string; mode: 'insensitive' } } = {
      cityId,
    };
    if (search) {
      where.name = { contains: search, mode: 'insensitive' };
    }

    return this.prisma.district.findMany({
      where,
      orderBy: { name: 'asc' },
      select: { id: true, name: true, cityId: true },
    });
  }

  async validateDistrictBelongsToCity(districtId: string, cityId: string) {
    const district = await this.prisma.district.findUnique({
      where: { id: districtId },
    });

    if (!district) {
      throw new BadRequestException('Geçersiz ilçe');
    }

    if (district.cityId !== cityId) {
      throw new BadRequestException('Seçilen ilçe bu ile ait değil');
    }
  }
}
