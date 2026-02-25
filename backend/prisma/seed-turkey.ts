import { PrismaClient } from '@prisma/client';
import * as path from 'path';
import * as fs from 'fs';

const prisma = new PrismaClient();
// türkiye ilçe verileri
interface DistrictJson {
  id: number;
  name: string;
}

interface CityJson {
  id: number;
  name: string;
  districts: DistrictJson[];
}

async function main() {
  const jsonPath = path.join(__dirname, 'Turkey.json');
  const raw = fs.readFileSync(jsonPath, 'utf-8');
  const data: CityJson[] = JSON.parse(raw);

  console.log(`Seeding ${data.length} cities from Turkey.json...`);

  let totalDistricts = 0;

  for (const cityJson of data) {
    const city = await prisma.city.upsert({
      where: { id: cityJson.id.toString() },
      update: { name: cityJson.name },
      create: {
        id: cityJson.id.toString(),
        name: cityJson.name,
      },
    });

    for (const distJson of cityJson.districts) {
      await prisma.district.upsert({
        where: { id: distJson.id.toString() },
        update: { name: distJson.name, cityId: city.id },
        create: {
          id: distJson.id.toString(),
          name: distJson.name,
          cityId: city.id,
        },
      });
      totalDistricts++;
    }
  }

  console.log(`✓ ${data.length} cities, ${totalDistricts} districts seeded`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
