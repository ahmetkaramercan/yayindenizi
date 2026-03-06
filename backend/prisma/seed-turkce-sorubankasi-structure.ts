import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Türkçe Soru Bankası';
const BOOK_IMAGE_URL = 'photos/turkce_soru_bankasi.jpeg';

const LETTER_TO_INDEX: Record<string, number> = {
  A: 0,
  B: 1,
  C: 2,
  D: 3,
  E: 4,
};

// Her konu bölümü: title, description ve testleri (cevap anahtarı)
const SECTIONS: {
  title: string;
  description: string;
  tests: { title: string; answers: string[] }[];
}[] = [
  {
    title: 'Sözcüğün Anlamı - Anlam Olayları',
    description: 'Sözcüğün anlamı ve anlam olaylarına ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'D', 'C', 'D', 'C', 'D', 'A', 'E', 'C', 'C'] },
      { title: 'Test 2', answers: ['C', 'C', 'A', 'C', 'E', 'B', 'A', 'C', 'E', 'E', 'C'] },
      { title: 'Test 3', answers: ['A', 'A', 'B', 'A', 'E', 'E', 'D', 'E', 'D', 'B', 'C'] },
      { title: 'Test 4', answers: ['A', 'B', 'D', 'C', 'C', 'D', 'B', 'C', 'A'] },
    ],
  },
  {
    title: 'Söz Öbeğinin Anlamı',
    description: 'Söz öbeğinin anlamına ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'B', 'A', 'B', 'B', 'E', 'C'] },
      { title: 'Test 2', answers: ['C', 'D', 'C', 'B', 'C', 'D', 'A', 'B'] },
      { title: 'Test 3', answers: ['D', 'B', 'A', 'B', 'A', 'D', 'C', 'A'] },
      { title: 'Test 4', answers: ['C', 'D', 'C', 'A', 'C', 'B', 'B', 'E'] },
      { title: 'Test 5', answers: ['C', 'B', 'B', 'E', 'D', 'A', 'E', 'B', 'A'] },
    ],
  },
  {
    title: 'Deyim - Atasözü - İkileme',
    description: 'Deyim, atasözü ve ikilemelere ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'C', 'E', 'B', 'D', 'E', 'B', 'D', 'B', 'C', 'B'] },
      { title: 'Test 2', answers: ['E', 'D', 'E', 'A', 'A', 'D', 'E', 'D', 'B', 'C', 'D', 'E'] },
      { title: 'Test 3', answers: ['A', 'E', 'D', 'C', 'E', 'B', 'D', 'B', 'B', 'C', 'D', 'C'] },
    ],
  },
  {
    title: 'Sözcükte ve Sözcük Gruplarında Anlam',
    description: 'Sözcükte ve sözcük gruplarında anlama ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'E', 'D', 'D', 'E', 'B', 'E', 'A', 'C', 'E', 'C'] },
      { title: 'Test 2', answers: ['D', 'B', 'C', 'E', 'D', 'B', 'D', 'C', 'D', 'C'] },
      { title: 'Test 3', answers: ['D', 'C', 'A', 'D', 'E', 'C', 'B', 'B', 'A'] },
      { title: 'Test 4', answers: ['B', 'D', 'C', 'C', 'C', 'A', 'D', 'E', 'A', 'C'] },
    ],
  },
  {
    title: 'Cümlede Anlam',
    description: 'Cümlede anlama ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'E', 'C', 'E', 'A', 'D', 'C', 'D'] },
      { title: 'Test 2', answers: ['C', 'C', 'B', 'B', 'D', 'C', 'B', 'D', 'B'] },
      { title: 'Test 3', answers: ['C', 'D', 'D', 'D', 'D', 'D', 'B', 'B', 'C'] },
      { title: 'Test 4', answers: ['D', 'B', 'B', 'C', 'B', 'D', 'C', 'E', 'C', 'A', 'A'] },
      { title: 'Test 5', answers: ['B', 'C', 'D', 'C', 'A', 'A', 'B', 'D', 'D', 'A'] },
      { title: 'Test 6', answers: ['D', 'A', 'D', 'E', 'A', 'D', 'C', 'B', 'D', 'B', 'B'] },
      { title: 'Test 7', answers: ['D', 'D', 'A', 'B', 'A', 'D', 'E', 'B', 'D', 'A', 'C', 'C'] },
      { title: 'Test 8', answers: ['B', 'C', 'E', 'B', 'B', 'C', 'D', 'B', 'D'] },
    ],
  },
  {
    title: 'Cümle Oluşturma - Cümle Tamamlama',
    description: 'Cümle oluşturma ve cümle tamamlamaya ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'D', 'E', 'C', 'C', 'D', 'C', 'C', 'B', 'C', 'C', 'B'] },
    ],
  },
  {
    title: 'Cümlede Kavramlar',
    description: 'Cümlede kavramlara ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'C', 'D', 'B', 'B', 'D', 'B', 'B', 'D', 'E', 'B', 'D'] },
      { title: 'Test 2', answers: ['C', 'E', 'B', 'E', 'D', 'A', 'B', 'A', 'B', 'B', 'B', 'E'] },
      { title: 'Test 3', answers: ['B', 'B', 'D', 'C', 'E', 'E', 'E', 'E', 'A', 'A', 'D'] },
    ],
  },
  {
    title: 'Cümlede Anlatım',
    description: 'Cümlede anlatıma ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'A', 'C', 'A', 'B', 'A', 'A', 'D', 'D', 'B', 'D', 'E'] },
      { title: 'Test 2', answers: ['B', 'D', 'D', 'A', 'C', 'B', 'E', 'B', 'E', 'C'] },
    ],
  },
  {
    title: 'Cümlede Anlam ve Anlatım Karma Test',
    description: 'Cümlede anlam ve anlatım karma testleri',
    tests: [
      { title: 'Test 1', answers: ['C', 'E', 'D', 'C', 'A', 'B', 'E', 'D', 'A', 'B'] },
      { title: 'Test 2', answers: ['B', 'A', 'C', 'E', 'E', 'C', 'D', 'B', 'C', 'B', 'C'] },
      { title: 'Test 3', answers: ['A', 'B', 'A', 'C', 'B', 'D', 'D', 'C', 'D', 'C'] },
      { title: 'Test 4', answers: ['C', 'D', 'E', 'D', 'E', 'C', 'C', 'C', 'D', 'D', 'D'] },
      { title: 'Test 5', answers: ['D', 'B', 'E', 'B', 'D', 'C', 'C', 'A', 'B'] },
    ],
  },
  {
    title: 'Paragrafta Anlatım',
    description: 'Paragrafta anlatıma ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'C', 'E', 'B', 'D', 'A', 'B', 'E', 'A'] },
      { title: 'Test 2', answers: ['D', 'E', 'A', 'D', 'C', 'E', 'D', 'B', 'E', 'C'] },
      { title: 'Test 3', answers: ['D', 'B', 'C', 'E', 'E', 'B', 'A', 'C'] },
      { title: 'Test 4', answers: ['D', 'C', 'C', 'E', 'C', 'B', 'E', 'A'] },
      { title: 'Test 5', answers: ['E', 'B', 'C', 'A', 'D', 'C', 'E', 'B'] },
      { title: 'Test 6', answers: ['E', 'B', 'A', 'E', 'B', 'A', 'D', 'B'] },
      { title: 'Test 7', answers: ['E', 'B', 'C', 'B', 'B', 'E', 'A', 'E'] },
      { title: 'Test 8', answers: ['E', 'A', 'B', 'D', 'E', 'C', 'C'] },
    ],
  },
  {
    title: 'Paragrafta Yapı',
    description: 'Paragrafta yapıya ait testler',
    tests: [
      { title: 'Test 1',  answers: ['B', 'B', 'C', 'C', 'E', 'C', 'A', 'A', 'C'] },
      { title: 'Test 2',  answers: ['C', 'D', 'C', 'A', 'A', 'D', 'B', 'C'] },
      { title: 'Test 3',  answers: ['B', 'D', 'C', 'E', 'D', 'E', 'E', 'E'] },
      { title: 'Test 4',  answers: ['B', 'D', 'B', 'D', 'C', 'C', 'E', 'C'] },
      { title: 'Test 5',  answers: ['B', 'C', 'C', 'B', 'D', 'E', 'E', 'D'] },
      { title: 'Test 6',  answers: ['C', 'B', 'C', 'D', 'C', 'B', 'E', 'A'] },
      { title: 'Test 7',  answers: ['D', 'B', 'A', 'B', 'E', 'D', 'A', 'C'] },
      { title: 'Test 8',  answers: ['E', 'C', 'C', 'B', 'E', 'D', 'A', 'E'] },
      { title: 'Test 9',  answers: ['D', 'B', 'D', 'B', 'E', 'C', 'D', 'A'] },
      { title: 'Test 10', answers: ['D', 'D', 'A', 'E', 'E', 'C', 'D', 'C', 'D', 'C'] },
      { title: 'Test 11', answers: ['E', 'D', 'C', 'C', 'B', 'A', 'A'] },
      { title: 'Test 12', answers: ['A', 'B', 'E', 'D', 'B', 'E', 'D', 'B'] },
      { title: 'Test 13', answers: ['C', 'B', 'A', 'D', 'C', 'D', 'A', 'B'] },
      { title: 'Test 14', answers: ['B', 'C', 'A', 'A', 'C', 'C', 'D'] },
    ],
  },
  {
    title: 'Paragrafta Anlam',
    description: 'Paragrafta anlama ait testler',
    tests: [
      { title: 'Test 1',  answers: ['C', 'E', 'C', 'E', 'A', 'B'] },
      { title: 'Test 2',  answers: ['D', 'C', 'D', 'A', 'C'] },
      { title: 'Test 3',  answers: ['A', 'C', 'D', 'A', 'A', 'A', 'B', 'E'] },
      { title: 'Test 4',  answers: ['A', 'C', 'C', 'E', 'D', 'D'] },
      { title: 'Test 5',  answers: ['B', 'D', 'D', 'B', 'C', 'E', 'E', 'A'] },
      { title: 'Test 6',  answers: ['C', 'C', 'B', 'A', 'A', 'C', 'B'] },
      { title: 'Test 7',  answers: ['B', 'E', 'C', 'B', 'A', 'E'] },
      { title: 'Test 8',  answers: ['E', 'E', 'B', 'B', 'C', 'B', 'B', 'D'] },
      { title: 'Test 9',  answers: ['D', 'D', 'C', 'E', 'A', 'B', 'A', 'C'] },
      { title: 'Test 10', answers: ['C', 'B', 'C', 'A', 'B', 'E'] },
      { title: 'Test 11', answers: ['E', 'C', 'B', 'D', 'C', 'A', 'C', 'D'] },
      { title: 'Test 12', answers: ['A', 'A', 'D', 'E', 'C', 'E', 'C'] },
      { title: 'Test 13', answers: ['D', 'E', 'B', 'C', 'C', 'C', 'D', 'D'] },
      { title: 'Test 14', answers: ['B', 'C', 'B', 'A', 'E', 'E', 'A', 'C'] },
      { title: 'Test 15', answers: ['B', 'D', 'A', 'A', 'C', 'C', 'D', 'D'] },
      { title: 'Test 16', answers: ['C', 'D', 'E', 'E', 'C', 'A', 'A', 'A'] },
      { title: 'Test 17', answers: ['C', 'C', 'E', 'D', 'B', 'B', 'A', 'D'] },
      { title: 'Test 18', answers: ['B', 'C', 'C', 'A', 'D', 'B', 'D'] },
      { title: 'Test 19', answers: ['E', 'C', 'B', 'C', 'C', 'A'] },
      { title: 'Test 20', answers: ['B', 'D', 'C', 'B', 'A'] },
      { title: 'Test 21', answers: ['A', 'B', 'C', 'B', 'E', 'C', 'A'] },
      { title: 'Test 22', answers: ['E', 'A', 'B', 'B', 'B', 'D', 'A'] },
      { title: 'Test 23', answers: ['E', 'A', 'B', 'E', 'E', 'B', 'C'] },
      { title: 'Test 24', answers: ['C', 'E', 'E', 'E', 'E', 'D', 'A'] },
      { title: 'Test 25', answers: ['B', 'B', 'A', 'B', 'B', 'D', 'D', 'B'] },
    ],
  },
  {
    title: 'Zincir Soru',
    description: 'Zincir sorulara ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'D', 'C', 'E', 'C', 'D', 'A', 'D'] },
      { title: 'Test 2', answers: ['A', 'C', 'D', 'B', 'B', 'B', 'C', 'C'] },
      { title: 'Test 3', answers: ['D', 'C', 'D', 'E', 'C', 'E', 'C', 'B', 'C'] },
      { title: 'Test 4', answers: ['E', 'C', 'B', 'C', 'D', 'E', 'B', 'E'] },
      { title: 'Test 5', answers: ['C', 'C', 'C', 'B', 'D', 'B', 'B', 'B'] },
    ],
  },
  {
    title: 'Paragraf Karma Sorular',
    description: 'Paragraf konularını bir arada içeren karma testler',
    tests: [
      { title: 'Test 1',  answers: ['E', 'A', 'D', 'C', 'B', 'B', 'D'] },
      { title: 'Test 2',  answers: ['E', 'C', 'C', 'A', 'A', 'C', 'C', 'E'] },
      { title: 'Test 3',  answers: ['C', 'A', 'B', 'D', 'E', 'C', 'B', 'B'] },
      { title: 'Test 4',  answers: ['C', 'B', 'B', 'C', 'D', 'A', 'D', 'C'] },
      { title: 'Test 5',  answers: ['B', 'D', 'D', 'C', 'D', 'B'] },
      { title: 'Test 6',  answers: ['B', 'B', 'E', 'C', 'C', 'B', 'E'] },
      { title: 'Test 7',  answers: ['D', 'E', 'C', 'B', 'E', 'D', 'C'] },
      { title: 'Test 8',  answers: ['D', 'A', 'A', 'E', 'C', 'E', 'C'] },
      { title: 'Test 9',  answers: ['A', 'A', 'C', 'D', 'A', 'C', 'A', 'A'] },
      { title: 'Test 10', answers: ['D', 'D', 'B', 'C', 'E', 'D'] },
    ],
  },
  {
    title: 'Ses Bilgisi',
    description: 'Ses bilgisine ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'B', 'A', 'C', 'D', 'E', 'A', 'E', 'D', 'B', 'D'] },
      { title: 'Test 2', answers: ['B', 'B', 'B', 'C', 'D', 'A', 'A', 'C', 'C', 'E'] },
      { title: 'Test 3', answers: ['E', 'D', 'B', 'C', 'A', 'E', 'B', 'B', 'E', 'D'] },
      { title: 'Test 4', answers: ['A', 'C', 'A', 'C', 'E', 'A', 'A', 'C', 'D', 'B'] },
    ],
  },
  {
    title: 'Yazım Kuralları',
    description: 'Yazım kurallarına ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'A', 'B', 'E', 'D', 'A', 'D', 'C', 'E', 'E'] },
      { title: 'Test 2', answers: ['A', 'B', 'A', 'D', 'B', 'C', 'B', 'D', 'D'] },
      { title: 'Test 3', answers: ['D', 'E', 'C', 'E', 'A', 'C', 'A', 'A', 'C', 'E', 'A', 'C'] },
      { title: 'Test 4', answers: ['E', 'A', 'B', 'A', 'E', 'D', 'E', 'D', 'C', 'D', 'D', 'A'] },
    ],
  },
  {
    title: 'Noktalama İşaretleri',
    description: 'Noktalama işaretlerine ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'C', 'A', 'B', 'E', 'E', 'A', 'E', 'A', 'A', 'E'] },
      { title: 'Test 2', answers: ['C', 'A', 'E', 'D', 'C', 'B', 'E', 'C', 'C', 'D', 'C'] },
      { title: 'Test 3', answers: ['B', 'A', 'E', 'B', 'D', 'C', 'A', 'D', 'D', 'B', 'A', 'D'] },
      { title: 'Test 4', answers: ['D', 'E', 'A', 'B', 'E', 'B', 'B', 'A', 'D', 'B', 'E', 'B'] },
    ],
  },
  {
    title: 'Ses Bilgisi - Yazım Kuralları - Noktalama İşaretleri Karma Testler',
    description: 'Ses bilgisi, yazım kuralları ve noktalama işaretleri karma testleri',
    tests: [
      { title: 'Test 1', answers: ['A', 'D', 'A', 'A', 'D', 'C', 'A', 'B', 'E', 'B', 'C'] },
      { title: 'Test 2', answers: ['D', 'D', 'E', 'B', 'E', 'C', 'C', 'C', 'E', 'B'] },
      { title: 'Test 3', answers: ['C', 'C', 'D', 'B', 'C', 'A', 'C', 'D', 'B', 'B'] },
      { title: 'Test 4', answers: ['B', 'C', 'A', 'B', 'D', 'E', 'B', 'E', 'A', 'C', 'D', 'B'] },
      { title: 'Test 5', answers: ['B', 'C', 'C', 'D', 'D', 'E', 'C', 'B', 'A', 'C'] },
    ],
  },
  {
    title: 'Kök - Ek Kavramları',
    description: 'Kök ve ek kavramlarına ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'A', 'C', 'B', 'A', 'A', 'C', 'C', 'C', 'C', 'C', 'C'] },
      { title: 'Test 2', answers: ['B', 'C', 'A', 'D', 'A', 'D', 'E', 'B', 'C', 'E', 'A', 'B'] },
    ],
  },
  {
    title: 'Sözcüğün Yapısı',
    description: 'Sözcüğün yapısına ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'C', 'A', 'D', 'D', 'E', 'C', 'E', 'E', 'A', 'D'] },
      { title: 'Test 2', answers: ['B', 'A', 'A', 'C', 'E', 'A', 'B', 'E', 'C', 'E', 'A', 'D'] },
    ],
  },
  {
    title: 'Sözcükte Yapı Karma Test',
    description: 'Sözcükte yapı karma testleri',
    tests: [
      { title: 'Test 1', answers: ['B', 'C', 'D', 'B', 'D', 'E', 'A', 'B', 'C', 'C', 'C'] },
      { title: 'Test 2', answers: ['A', 'B', 'A', 'C', 'D', 'E', 'D', 'B', 'E', 'E', 'E', 'B'] },
    ],
  },
  {
    title: 'İsim (Ad)',
    description: 'İsim (Ad) konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'D', 'C', 'B', 'C', 'A', 'D', 'D', 'A', 'E', 'C', 'E'] },
      { title: 'Test 2', answers: ['C', 'D', 'D', 'D', 'A', 'D', 'A', 'C', 'E', 'B', 'E'] },
      { title: 'Test 3', answers: ['A', 'D', 'D', 'B', 'C', 'E', 'B', 'C', 'E', 'E'] },
    ],
  },
  {
    title: 'Sıfat (Ön Ad)',
    description: 'Sıfat (Ön Ad) konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'C', 'B', 'E', 'C', 'D', 'E', 'E', 'C', 'E', 'B', 'A'] },
      { title: 'Test 2', answers: ['D', 'E', 'A', 'B', 'A', 'B', 'A', 'B', 'A', 'A', 'E', 'A'] },
      { title: 'Test 3', answers: ['A', 'A', 'E', 'A', 'C', 'B', 'E', 'C', 'D', 'B', 'E'] },
    ],
  },
  {
    title: 'Tamlamalar',
    description: 'Tamlamalara ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'C', 'B', 'E', 'E', 'E', 'B', 'C', 'E', 'D', 'A', 'B'] },
      { title: 'Test 2', answers: ['E', 'A', 'E', 'C', 'D', 'C', 'A', 'C', 'E'] },
      { title: 'Test 3', answers: ['C', 'C', 'C', 'C', 'B', 'B', 'C', 'E', 'E', 'A', 'E', 'C'] },
      { title: 'Test 4', answers: ['D', 'A', 'D', 'C', 'E', 'D', 'A', 'E', 'A', 'A', 'B'] },
    ],
  },
  {
    title: 'Zamir (Adıl)',
    description: 'Zamir (Adıl) konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'C', 'C', 'A', 'E', 'E', 'E', 'D', 'C', 'E', 'C', 'C'] },
      { title: 'Test 2', answers: ['D', 'A', 'C', 'B', 'A', 'B', 'D', 'B', 'C', 'E', 'B'] },
      { title: 'Test 3', answers: ['E', 'E', 'C', 'A', 'C', 'A', 'D', 'C', 'E', 'E', 'A', 'B'] },
      { title: 'Test 4', answers: ['E', 'C', 'D', 'E', 'B', 'C', 'D', 'D', 'D', 'A', 'E', 'C'] },
    ],
  },
  {
    title: 'Zarf (Belirteç)',
    description: 'Zarf (Belirteç) konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'C', 'B', 'E', 'C', 'D', 'C', 'A', 'D', 'D', 'E'] },
      { title: 'Test 2', answers: ['E', 'C', 'C', 'E', 'B', 'D', 'B', 'C', 'B', 'B', 'C', 'D', 'E'] },
      { title: 'Test 3', answers: ['C', 'E', 'A', 'D', 'A', 'C', 'E', 'A', 'A', 'C', 'B', 'A'] },
      { title: 'Test 4', answers: ['D', 'A', 'C', 'C', 'B', 'B', 'D', 'E', 'B', 'E', 'C', 'E'] },
    ],
  },
  {
    title: 'Edat - Bağlaç - Ünlem',
    description: 'Edat, bağlaç ve ünleme ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'D', 'C', 'D', 'E', 'C', 'A', 'E', 'C', 'D', 'B', 'A'] },
      { title: 'Test 2', answers: ['E', 'A', 'C', 'D', 'E', 'D', 'C', 'E', 'D', 'A', 'C', 'C'] },
      { title: 'Test 3', answers: ['C', 'E', 'A', 'B', 'A', 'E', 'E', 'A', 'D', 'C', 'C', 'A', 'C'] },
      { title: 'Test 4', answers: ['B', 'A', 'E', 'E', 'A', 'D', 'C', 'C', 'D', 'B', 'B', 'B'] },
    ],
  },
  {
    title: 'Fiilde Anlam ve Kip / Ek Fiil',
    description: 'Fiilde anlam ve kip / ek fiil konularına ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'D', 'E', 'A', 'C', 'A', 'D', 'A', 'C', 'B', 'B', 'B'] },
      { title: 'Test 2', answers: ['A', 'C', 'A', 'D', 'B', 'B', 'A', 'B', 'D', 'B', 'C', 'D'] },
    ],
  },
  {
    title: 'Fiilde Yapı',
    description: 'Fiilde yapı konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'A', 'D', 'D', 'B', 'B', 'C', 'D', 'E', 'E', 'C', 'A'] },
      { title: 'Test 2', answers: ['A', 'D', 'D', 'C', 'D', 'C', 'A', 'A', 'E', 'A', 'C'] },
    ],
  },
  {
    title: 'Fiilimsiler',
    description: 'Fiilimsiler konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'E', 'B', 'E', 'A', 'A', 'D', 'E', 'D', 'C', 'A', 'B'] },
      { title: 'Test 2', answers: ['A', 'E', 'B', 'C', 'C', 'B', 'A', 'B', 'B', 'B', 'C', 'B'] },
      { title: 'Test 3', answers: ['D', 'E', 'D', 'E', 'B', 'E', 'C', 'A', 'E', 'B', 'A', 'C'] },
      { title: 'Test 4', answers: ['A', 'A', 'C', 'D', 'B', 'A', 'C', 'B', 'C', 'B', 'E'] },
    ],
  },
  {
    title: 'Fiilde Çatı',
    description: 'Fiilde çatı konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'B', 'B', 'C', 'A', 'C', 'A', 'C', 'B', 'D', 'A', 'E'] },
      { title: 'Test 2', answers: ['B', 'B', 'A', 'A', 'B', 'E', 'B', 'D', 'C', 'D', 'C'] },
      { title: 'Test 3', answers: ['D', 'B', 'A', 'C', 'E', 'C', 'A', 'C', 'C', 'D', 'D', 'B'] },
    ],
  },
  {
    title: 'Sözcük Türleri Karma Test',
    description: 'Sözcük türleri karma testleri',
    tests: [
      { title: 'Test 1', answers: ['D', 'A', 'B', 'D', 'E', 'D', 'E', 'A', 'E', 'A', 'E', 'E'] },
      { title: 'Test 2', answers: ['E', 'C', 'D', 'B', 'C', 'C', 'B', 'D', 'D', 'D', 'D', 'A'] },
      { title: 'Test 3', answers: ['E', 'D', 'C', 'E', 'A', 'D', 'B', 'B', 'D', 'D', 'E'] },
      { title: 'Test 4', answers: ['B', 'C', 'C', 'A', 'D', 'B', 'B', 'B', 'D', 'B', 'B', 'D'] },
      { title: 'Test 5', answers: ['A', 'A', 'A', 'D', 'A', 'C', 'B', 'C', 'D', 'D', 'C'] },
      { title: 'Test 6', answers: ['D', 'B', 'E', 'D', 'E', 'B', 'C', 'C', 'E', 'B', 'A'] },
      { title: 'Test 7', answers: ['C', 'D', 'B', 'B', 'A', 'D', 'B', 'E', 'D', 'D', 'C', 'E'] },
      { title: 'Test 8', answers: ['B', 'B', 'E', 'A', 'C', 'D', 'B', 'E', 'E', 'B', 'E'] },
    ],
  },
  {
    title: 'Cümlenin Ögeleri',
    description: 'Cümlenin ögelerine ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'D', 'A', 'C', 'B', 'C', 'B', 'D', 'E', 'D', 'A'] },
      { title: 'Test 2', answers: ['D', 'C', 'C', 'B', 'D', 'B', 'E', 'C', 'E', 'E', 'E', 'C'] },
      { title: 'Test 3', answers: ['C', 'C', 'C', 'A', 'B', 'B', 'D', 'C', 'C', 'B', 'D', 'A'] },
      { title: 'Test 4', answers: ['A', 'B', 'E', 'B', 'A', 'D', 'E', 'D', 'D'] },
    ],
  },
  {
    title: 'Cümle Türleri',
    description: 'Cümle türlerine ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'A', 'A', 'B', 'D', 'B', 'D', 'A', 'C', 'B', 'C', 'B'] },
      { title: 'Test 2', answers: ['A', 'C', 'B', 'B', 'E', 'B', 'C', 'B', 'E', 'C', 'A', 'C'] },
      { title: 'Test 3', answers: ['E', 'A', 'B', 'D', 'D', 'A', 'D', 'E', 'A', 'A', 'D'] },
      { title: 'Test 4', answers: ['B', 'B', 'D', 'B', 'B', 'B', 'A', 'E', 'A', 'A', 'D', 'C'] },
    ],
  },
  {
    title: 'Cümle Bilgisi Karma Test',
    description: 'Cümle bilgisi karma testleri',
    tests: [
      { title: 'Test 1', answers: ['B', 'B', 'C', 'A', 'B', 'C', 'E', 'E', 'B', 'C', 'B', 'B', 'D'] },
    ],
  },
  {
    title: 'Dil Bilgisi Karma Testler',
    description: 'Dil bilgisi karma testleri',
    tests: [
      { title: 'Test 1', answers: ['A', 'C', 'D', 'D', 'A', 'D', 'D', 'C', 'B', 'A', 'E'] },
      { title: 'Test 2', answers: ['B', 'E', 'A', 'E', 'A', 'C', 'B', 'C', 'B', 'B', 'D', 'C'] },
      { title: 'Test 3', answers: ['C', 'B', 'E', 'D', 'C', 'A', 'A', 'D', 'E', 'C', 'C', 'C'] },
      { title: 'Test 4', answers: ['D', 'B', 'A', 'E', 'C', 'A', 'C', 'B', 'E', 'E', 'A'] },
      { title: 'Test 5', answers: ['B', 'D', 'D', 'E', 'E', 'B', 'B', 'E', 'C', 'C', 'E', 'D'] },
    ],
  },
  {
    title: 'Anlama Dayalı Anlatım Bozuklukları',
    description: 'Anlama dayalı anlatım bozukluklarına ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'C', 'C', 'A', 'E', 'C', 'D', 'B', 'B', 'C', 'E'] },
      { title: 'Test 2', answers: ['D', 'A', 'E', 'E', 'D', 'E', 'D', 'B', 'E', 'C', 'D', 'E'] },
    ],
  },
  {
    title: 'Dil Bilgisi Dayalı Anlatım Bozuklukları',
    description: 'Dil bilgisi dayalı anlatım bozukluklarına ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'C', 'B', 'C', 'E', 'C', 'D', 'B', 'C', 'B', 'C'] },
      { title: 'Test 2', answers: ['C', 'C', 'A', 'A', 'C', 'B', 'C', 'B', 'B', 'D', 'D', 'C'] },
    ],
  },
];

async function main() {
  console.log('Seeding Türkçe Soru Bankası - structure (sections, tests, questions)');

  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT Türkçe konu bazlı soru bankası',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.KONU,
      },
      select: { id: true },
    });
    console.log(`✓ Book created: ${book.id}`);
  } else {
    await prisma.book.update({
      where: { id: book.id },
      data: {
        title: BOOK_TITLE,
        description: 'TYT Türkçe konu bazlı soru bankası',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.KONU,
      },
    });
    console.log(`✓ Book found: ${book.id}`);
  }

  const bookId = book.id;

  const existingSections = await prisma.section.findMany({
    where: { bookId },
    select: { id: true },
  });
  if (existingSections.length > 0) {
    await prisma.section.deleteMany({ where: { bookId } });
    console.log(`✓ Removed ${existingSections.length} existing sections`);
  }

  let totalSections = 0;
  let totalTests = 0;
  let totalQuestions = 0;

  for (let sIdx = 0; sIdx < SECTIONS.length; sIdx++) {
    const sectionData = SECTIONS[sIdx];

    const section = await prisma.section.create({
      data: {
        title: sectionData.title,
        description: sectionData.description,
        orderIndex: sIdx,
        bookId,
      },
    });
    totalSections++;

    for (let tIdx = 0; tIdx < sectionData.tests.length; tIdx++) {
      const testData = sectionData.tests[tIdx];

      const test = await prisma.test.create({
        data: {
          title: testData.title,
          description: testData.title,
          level: 1,
          timeLimit: testData.answers.length * 72, // ~72 saniye/soru
          sectionId: section.id,
        },
      });
      totalTests++;

      const questions = testData.answers.map((letter, orderIndex) => {
        const idx = LETTER_TO_INDEX[letter.toUpperCase()] ?? 0;
        return {
          text: '',
          optionA: 'A',
          optionB: 'B',
          optionC: 'C',
          optionD: 'D',
          optionE: 'E',
          correctAnswerIndex: idx,
          orderIndex,
          testId: test.id,
        };
      });

      await prisma.question.createMany({ data: questions });
      totalQuestions += questions.length;
    }
  }

  console.log(`✓ ${totalSections} sections created`);
  console.log(`✓ ${totalTests} tests created`);
  console.log(`✓ ${totalQuestions} questions created`);

  console.log('\n=== VALIDATION ===');
  const sectionCount = await prisma.section.count({ where: { bookId } });
  const testCount = await prisma.test.count({ where: { section: { bookId } } });
  const questionCount = await prisma.question.count({ where: { test: { section: { bookId } } } });
  console.log(`Sections: ${sectionCount}`);
  console.log(`Tests: ${testCount}`);
  console.log(`Questions: ${questionCount}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
