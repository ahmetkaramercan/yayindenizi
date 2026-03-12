import { PrismaClient, Role, BookCategory } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { seedTurkey } from './seed-turkey';

const prisma = new PrismaClient();

async function main() {
  // İl / İlçe verilerini seed et
  await seedTurkey(prisma);

  const hashedPassword = await bcrypt.hash('password123', 10);

  // Admin
  const admin = await prisma.user.upsert({
    where: { email: 'admin@yayindenizi.com' },
    update: {},
    create: {
      email: 'admin@yayindenizi.com',
      password: hashedPassword,
      role: Role.ADMIN,
      adSoyad: 'Sistem Admin',
    },
  });

  // Teacher
  const teacher = await prisma.user.upsert({
    where: { email: 'ogretmen@yayindenizi.com' },
    update: {},
    create: {
      email: 'ogretmen@yayindenizi.com',
      password: hashedPassword,
      role: Role.TEACHER,
      adSoyad: 'Ahmet Yılmaz',
      okul: 'Atatürk Anadolu Lisesi',
    },
  });

  // Student
  const student = await prisma.user.upsert({
    where: { email: 'ogrenci@yayindenizi.com' },
    update: {},
    create: {
      email: 'ogrenci@yayindenizi.com',
      password: hashedPassword,
      role: Role.STUDENT,
      adSoyad: 'Elif Demir',
    },
  });

  // Create a classroom for the teacher and add the student (idempotent)
  const classroom = await prisma.classroom.upsert({
    where: { code: 'ABCD1234' },
    update: {},
    create: {
      name: '9-A Türkçe',
      code: 'ABCD1234',
      teacherId: teacher.id,
      students: {
        create: { studentId: student.id },
      },
    },
  });

  // Learning outcomes (generic seed codes — idempotent)
  const outcomeData = [
    { code: 'SEED.1',  name: 'Paragrafta Anlam',  category: 'Paragraf',    description: 'Paragrafın ana fikrini, yardımcı fikirlerini ve konusunu belirleme' },
    { code: 'SEED.2',  name: 'Paragraf Yapısı',   category: 'Paragraf',    description: 'Paragrafın giriş, gelişme, sonuç bölümlerini tanıma' },
    { code: 'SEED.3',  name: 'Paragraf Tamamlama',category: 'Paragraf',    description: 'Paragrafı uygun cümlelerle tamamlama' },
    { code: 'SEED.4',  name: 'Cümlede Anlam',     category: 'Cümle',       description: 'Cümlenin anlamını kavrama ve yorumlama' },
    { code: 'SEED.5',  name: 'Cümle Yapısı',      category: 'Cümle',       description: 'Cümlenin yapısal özelliklerini tanıma' },
    { code: 'SEED.6',  name: 'Cümle Tamamlama',   category: 'Cümle',       description: 'Cümleyi uygun sözcük veya ifadelerle tamamlama' },
    { code: 'SEED.7',  name: 'Kelime Anlamı',     category: 'Kelime',      description: 'Sözcüklerin anlamlarını kavrama' },
    { code: 'SEED.8',  name: 'Deyim ve Atasözü',  category: 'Kelime',      description: 'Deyim ve atasözlerini tanıma ve yorumlama' },
    { code: 'SEED.9',  name: 'Ses Bilgisi',        category: 'Dil Bilgisi', description: 'Ses olaylarını ve kurallarını bilme' },
    { code: 'SEED.10', name: 'Ekler',              category: 'Dil Bilgisi', description: 'Yapım ve çekim eklerini tanıma' },
    { code: 'SEED.11', name: 'Sözcük Türleri',    category: 'Dil Bilgisi', description: 'Sözcük türlerini ayırt etme' },
  ];
  const outcomes = await Promise.all(
    outcomeData.map(async (d) => {
      const existing = await prisma.learningOutcome.findFirst({
        where: { code: d.code, bookId: null },
      });
      if (existing) return existing;
      return prisma.learningOutcome.create({ data: d });
    }),
  );

  console.log('Seed completed:', {
    admin: admin.id,
    teacher: teacher.id,
    student: student.id,
    classroom: classroom.id,
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
