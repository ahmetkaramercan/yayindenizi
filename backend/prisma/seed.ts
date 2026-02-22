import { PrismaClient, Role, BookCategory } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
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
      il: 'İstanbul',
      ilce: 'Kadıköy',
      okul: 'Atatürk Anadolu Lisesi',
      ogretmenKodu: 'OGR001',
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
      il: 'İstanbul',
      ilce: 'Beşiktaş',
    },
  });

  // Teacher-Student relation
  await prisma.teacherStudent.upsert({
    where: { teacherId_studentId: { teacherId: teacher.id, studentId: student.id } },
    update: {},
    create: { teacherId: teacher.id, studentId: student.id },
  });

  // Learning outcomes (generic seed codes)
  const outcomes = await Promise.all([
    prisma.learningOutcome.create({ data: { code: 'SEED.1', name: 'Paragrafta Anlam', category: 'Paragraf', description: 'Paragrafın ana fikrini, yardımcı fikirlerini ve konusunu belirleme' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.2', name: 'Paragraf Yapısı', category: 'Paragraf', description: 'Paragrafın giriş, gelişme, sonuç bölümlerini tanıma' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.3', name: 'Paragraf Tamamlama', category: 'Paragraf', description: 'Paragrafı uygun cümlelerle tamamlama' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.4', name: 'Cümlede Anlam', category: 'Cümle', description: 'Cümlenin anlamını kavrama ve yorumlama' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.5', name: 'Cümle Yapısı', category: 'Cümle', description: 'Cümlenin yapısal özelliklerini tanıma' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.6', name: 'Cümle Tamamlama', category: 'Cümle', description: 'Cümleyi uygun sözcük veya ifadelerle tamamlama' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.7', name: 'Kelime Anlamı', category: 'Kelime', description: 'Sözcüklerin anlamlarını kavrama' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.8', name: 'Deyim ve Atasözü', category: 'Kelime', description: 'Deyim ve atasözlerini tanıma ve yorumlama' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.9', name: 'Ses Bilgisi', category: 'Dil Bilgisi', description: 'Ses olaylarını ve kurallarını bilme' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.10', name: 'Ekler', category: 'Dil Bilgisi', description: 'Yapım ve çekim eklerini tanıma' } }),
    prisma.learningOutcome.create({ data: { code: 'SEED.11', name: 'Sözcük Türleri', category: 'Dil Bilgisi', description: 'Sözcük türlerini ayırt etme' } }),
  ]);

  // Book → Section → Test → Question
  const book = await prisma.book.create({
    data: {
      title: 'Paragraf Koçu',
      description: 'TYT Paragraf çalışma kitabı',
      category: BookCategory.PARAGRAF,
      sections: {
        create: [
          {
            title: 'Ana Fikir',
            description: 'Paragrafın ana fikrini bulma',
            orderIndex: 0,
            tests: {
              create: {
                title: 'Ana Fikir Testi - Seviye 1',
                level: 1,
                timeLimit: 600,
                questions: {
                  create: [
                    {
                      text: 'Aşağıdaki paragrafın ana fikri nedir?\n\n"Kitap okumak, insanın hayal dünyasını genişletir. Farklı kültürleri, farklı yaşam biçimlerini tanımamızı sağlar. Okudukça dünyaya bakış açımız değişir ve zenginleşir."',
                      optionA: 'A',
                      optionB: 'B',
                      optionC: 'C',
                      optionD: 'D',
                      optionE: 'E',
                      correctAnswerIndex: 1,
                      explanation: 'Paragrafta kitap okumanın hayal dünyasını genişlettiği, bakış açısını değiştirdiği vurgulanmaktadır.',
                      orderIndex: 0,
                      learningOutcomeId: outcomes[0].id,
                    },
                  ],
                },
              },
            },
          },
          {
            title: 'Yardımcı Fikir',
            description: 'Paragraftaki yardımcı fikirleri belirleme',
            orderIndex: 1,
          },
        ],
      },
    },
  });

  console.log('Seed completed:', {
    admin: admin.id,
    teacher: teacher.id,
    student: student.id,
    book: book.id,
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
