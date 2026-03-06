import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Edebiyat Soru Bankası';
const BOOK_IMAGE_URL = 'photos/edebiyat_soru_bankasi.jpeg';

const LETTER_TO_INDEX: Record<string, number> = {
  A: 0,
  B: 1,
  C: 2,
  D: 3,
  E: 4,
};

const SECTIONS: {
  title: string;
  description: string;
  tests: { title: string; answers: string[] }[];
}[] = [
  // ─── EDEBİYATA GİRİŞ ────────────────────────────────────────────────────────
  {
    title: 'Edebiyat - Edebiyatın Diğer Sanatlarla ve Bilimle İlişkisi',
    description: 'Edebiyatın diğer sanatlar ve bilimle ilişkisine ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'A', 'E', 'D', 'D', 'E', 'E'] },
    ],
  },
  {
    title: 'Edebiyatın Tarih ve Din ile İlişkisi / Türkçenin Tarihî Gelişimi / Türk Edebiyatının Tarihî Dönemleri',
    description: 'Edebiyatın tarih ve din ile ilişkisi; Türkçenin ve Türk edebiyatının tarihî gelişimine ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'B', 'A', 'D', 'B', 'D', 'B', 'A', 'E', 'C', 'A', 'E'] },
    ],
  },
  {
    title: 'Edebiyatın Tarih ve Din ile İlişkisi / Türkçenin Tarihî Gelişimi / Türk Edebiyatının Tarihî Dönemleri / Edebiyat ve Toplum İlişkisi / Edebiyat Sanat Akımları ile İlişkisi',
    description: 'Edebiyat ile tarih, din, toplum ve sanat akımları ilişkisine ait karma testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'C', 'B', 'E', 'C', 'B', 'A', 'E', 'A'] },
    ],
  },
  {
    title: 'Edebiyat ve Felsefe İlişkisi / Edebiyat ve Psikoloji İlişkisi / Dilin Tarihî Süreç İçerisindeki Değişimi / Türkçenin Önemli Sözlükleri',
    description: 'Edebiyat ve felsefe/psikoloji ilişkisi; dilin tarihî değişimi ve Türkçe sözlüklere ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'D', 'B', 'E', 'C', 'D', 'A', 'A', 'B', 'C', 'C'] },
    ],
  },
  // ─── ŞİİR ───────────────────────────────────────────────────────────────────
  {
    title: 'Şiir (Tür Bilgisi)',
    description: 'Şiir türüne ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'E', 'C', 'C', 'C', 'A', 'D', 'D', 'B', 'A'] },
      { title: 'Test 2', answers: ['E', 'B', 'B', 'D', 'E', 'C', 'D', 'E', 'E'] },
      { title: 'Test 3', answers: ['C', 'E', 'B', 'E', 'C', 'E', 'A', 'D'] },
      { title: 'Test 4', answers: ['C', 'E', 'C', 'B', 'A', 'C', 'B', 'D', 'E', 'E', 'D'] },
      { title: 'Test 5', answers: ['D', 'A', 'B', 'D', 'E', 'C', 'C', 'B'] },
      { title: 'Test 6', answers: ['E', 'C', 'B', 'E', 'D', 'E', 'B'] },
      { title: 'Test 7', answers: ['D', 'E', 'B', 'E', 'D', 'D', 'D', 'A'] },
      { title: 'Test 8', answers: ['A', 'A', 'B', 'D', 'A', 'D', 'E', 'A', 'C', 'A', 'B', 'D'] },
    ],
  },
  {
    title: 'Edebî Sanatlar',
    description: 'Edebî sanatlara ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'A', 'E', 'E', 'B', 'D', 'C', 'D', 'D'] },
      { title: 'Test 2', answers: ['B', 'C', 'A', 'A', 'B', 'C', 'D', 'D', 'A', 'C', 'B', 'B'] },
      { title: 'Test 3', answers: ['C', 'C', 'E', 'D', 'D', 'B', 'B', 'A', 'C'] },
      { title: 'Test 4', answers: ['D', 'A', 'E', 'E', 'A', 'B', 'B', 'E'] },
      { title: 'Test 5', answers: ['D', 'D', 'B', 'D', 'E', 'B', 'C', 'A', 'D'] },
    ],
  },
  // ─── TARİHÎ DÖNEMLER ────────────────────────────────────────────────────────
  {
    title: 'İslamiyet Öncesi Sözlü ve Yazılı Ürünler',
    description: 'İslamiyet öncesi sözlü ve yazılı ürünlere ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'A', 'C', 'E', 'C', 'E', 'D', 'C', 'E', 'E', 'C'] },
      { title: 'Test 2', answers: ['C', 'A', 'C', 'A', 'B', 'C', 'E', 'C', 'B'] },
    ],
  },
  {
    title: 'Geçiş Dönemi Ürünleri',
    description: 'Geçiş dönemi ürünlerine ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'A', 'E', 'C', 'C', 'D', 'B', 'D', 'D', 'B', 'A'] },
      { title: 'Test 2', answers: ['A', 'D', 'B', 'E', 'B', 'C', 'E', 'C', 'D', 'C'] },
    ],
  },
  {
    title: 'Halk Edebiyatında Şiir (Anonim Halk Edebiyatı)',
    description: 'Anonim halk edebiyatında şiire ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'E', 'A', 'C', 'B', 'D', 'E', 'C'] },
      { title: 'Test 2', answers: ['E', 'E', 'C', 'A', 'B', 'D', 'C', 'C'] },
    ],
  },
  {
    title: 'Halk Edebiyatında Şiir (Âşık Edebiyatı)',
    description: 'Âşık edebiyatında şiire ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'D', 'E', 'B', 'D', 'A', 'B', 'D', 'B'] },
      { title: 'Test 2', answers: ['C', 'E', 'C', 'E', 'D', 'A', 'B', 'C', 'B', 'B', 'D'] },
      { title: 'Test 3', answers: ['A', 'E', 'D', 'C', 'E', 'A', 'D', 'D', 'E'] },
    ],
  },
  {
    title: 'Halk Edebiyatında Şiir (Tekke Edebiyatı)',
    description: 'Tekke edebiyatında şiire ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'D', 'E', 'D', 'C', 'D', 'C', 'E', 'E'] },
      { title: 'Test 2', answers: ['D', 'B', 'D', 'B', 'A', 'C', 'B', 'D'] },
    ],
  },
  {
    title: 'Divan Edebiyatında Şiir',
    description: 'Divan edebiyatında şiire ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'B', 'E', 'D', 'B', 'B', 'E', 'C', 'D', 'B', 'B'] },
      { title: 'Test 2', answers: ['C', 'A', 'C', 'D', 'E', 'D', 'A', 'C', 'D', 'B', 'B', 'D'] },
      { title: 'Test 3', answers: ['E', 'D', 'E', 'C', 'B', 'A', 'E', 'C', 'A', 'D'] },
      { title: 'Test 4', answers: ['D', 'B', 'B', 'A', 'D', 'D', 'D', 'A', 'C', 'C'] },
      { title: 'Test 5', answers: ['C', 'E', 'D', 'A', 'C', 'E', 'A', 'C', 'D', 'C', 'C'] },
      { title: 'Test 6', answers: ['B', 'E', 'A', 'B', 'C', 'A', 'E', 'D', 'D', 'B', 'C', 'E'] },
    ],
  },
  // ─── TANZİMAT'TAN CUMHURİYET'E ŞİİR ────────────────────────────────────────
  {
    title: "Tanzimat Dönemi'nde Şiir",
    description: "Tanzimat dönemi şiirine ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'A', 'D', 'C', 'C', 'C', 'D', 'C'] },
      { title: 'Test 2', answers: ['D', 'B', 'E', 'C', 'D', 'D', 'E', 'D', 'C'] },
      { title: 'Test 3', answers: ['E', 'E', 'D', 'D', 'E', 'B', 'C', 'E', 'D', 'A', 'C'] },
    ],
  },
  {
    title: "Servetifünun Dönemi'nde Şiir",
    description: "Servetifünun dönemi şiirine ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'E', 'B', 'A', 'E', 'B', 'C', 'A', 'C', 'B'] },
      { title: 'Test 2', answers: ['A', 'D', 'E', 'E', 'D', 'E', 'E', 'A', 'B', 'E'] },
      { title: 'Test 3', answers: ['D', 'B', 'B', 'C', 'A', 'A', 'E', 'E', 'C'] },
    ],
  },
  {
    title: 'Fecriati Edebiyatında Şiir',
    description: 'Fecriati edebiyatında şiire ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'E', 'C', 'D', 'E', 'E', 'E', 'D', 'B'] },
      { title: 'Test 2', answers: ['A', 'C', 'C', 'A', 'D', 'A', 'D', 'A', 'D', 'D'] },
    ],
  },
  {
    title: "Millî Edebiyat Dönemi'nde Şiir",
    description: "Millî edebiyat dönemi şiirine ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'B', 'B', 'E', 'C', 'D', 'C', 'C', 'B'] },
      { title: 'Test 2', answers: ['A', 'E', 'E', 'E', 'E', 'B', 'C'] },
    ],
  },
  // ─── CUMHURİYET DÖNEMİ ŞİİR ─────────────────────────────────────────────────
  {
    title: "Cumhuriyet Dönemi'nde Şiir (Saf Şiir)",
    description: "Cumhuriyet dönemi saf şiirine ait testler",
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'B', 'B', 'E', 'E', 'D', 'B', 'A', 'C'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (Millî Edebiyat Zevk ve Anlayışını Sürdüren Şiir / Beş Hececiler - Yedi Meşaleciler)",
    description: "Millî edebiyat zevkini sürdüren şiir; Beş Hececiler ve Yedi Meşalecilere ait testler",
    tests: [
      { title: 'Test 1', answers: ['B', 'C', 'D', 'E', 'A', 'C', 'D', 'A', 'C', 'E', 'C', 'D'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (Toplumcu Gerçekçi Şiir / 1923-1960)",
    description: "Cumhuriyet dönemi toplumcu gerçekçi şiirine (1923-1960) ait testler",
    tests: [
      { title: 'Test 1', answers: ['B', 'E', 'A', 'B', 'E', 'C', 'D', 'C', 'E', 'C'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (Garip Akımı - Maviciler)",
    description: "Garip akımı ve Mavicilere ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'E', 'C', 'B', 'D', 'C', 'B', 'A', 'E', 'C', 'D'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (Garip Dışında Yeniliği Sürdüren Şiir)",
    description: "Garip dışında yeniliği sürdüren şiire ait testler",
    tests: [
      { title: 'Test 1', answers: ['A', 'E', 'B', 'D', 'E', 'C', 'B', 'C', 'E', 'A'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (İkinci Yeni Şiiri)",
    description: "İkinci Yeni şiirine ait testler",
    tests: [
      { title: 'Test 1', answers: ['B', 'C', 'D', 'E', 'A', 'B', 'A', 'C', 'E', 'D', 'D'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (Mistik-Metafizik Şiir)",
    description: "Mistik-metafizik şiire ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'C', 'B', 'D', 'C', 'C', 'B', 'A', 'E'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (1960 Sonrası Toplumcu Şiir)",
    description: "1960 sonrası toplumcu şiire ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'A', 'D', 'C', 'A', 'E', 'B', 'C', 'E', 'C'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (1980 Sonrası Şiir)",
    description: "1980 sonrası şiire ait testler",
    tests: [
      { title: 'Test 1', answers: ['C', 'D', 'C', 'D', 'D', 'B', 'A', 'E', 'D', 'E'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir (Halk Şiiri)",
    description: "Cumhuriyet dönemi halk şiirine ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'E', 'C', 'B', 'E', 'C', 'A', 'C', 'B', 'B'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Şiir Karma Test",
    description: "Cumhuriyet dönemi şiirini kapsayan karma testler",
    tests: [
      { title: 'Test 1', answers: ['A', 'E', 'A', 'E', 'B', 'D', 'A', 'C', 'D', 'E'] },
      { title: 'Test 2', answers: ['B', 'E', 'C', 'D', 'A', 'B', 'E', 'D', 'B', 'C'] },
      { title: 'Test 3', answers: ['D', 'C', 'A', 'E', 'B', 'D', 'A', 'C'] },
      { title: 'Test 4', answers: ['B', 'D', 'E', 'D', 'E', 'C', 'C', 'D', 'A'] },
      { title: 'Test 5', answers: ['D', 'B', 'C', 'D', 'D', 'E', 'B', 'E'] },
    ],
  },
  // ─── HİKÂYE ─────────────────────────────────────────────────────────────────
  {
    title: 'Hikâye (Tür Bilgisi)',
    description: 'Hikâye türüne ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'E', 'C', 'B', 'E', 'B', 'E', 'B'] },
      { title: 'Test 2', answers: ['D', 'B', 'A', 'D', 'E', 'B', 'A', 'C', 'D'] },
      { title: 'Test 3', answers: ['D', 'B', 'B', 'B', 'C', 'C'] },
      { title: 'Test 4', answers: ['C', 'C', 'A', 'E', 'C', 'E', 'C'] },
      { title: 'Test 5', answers: ['E', 'E', 'A', 'E', 'C'] },
      { title: 'Test 6', answers: ['D', 'D', 'C', 'B', 'C', 'E', 'B'] },
    ],
  },
  {
    title: 'Masal – Fabl – Destan – Efsane',
    description: 'Masal, fabl, destan ve efsaneye ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'E', 'D', 'C', 'A', 'B', 'B', 'D', 'C', 'C'] },
      { title: 'Test 2', answers: ['D', 'A', 'E', 'A', 'B', 'C', 'D', 'C', 'B', 'B'] },
      { title: 'Test 3', answers: ['B', 'E', 'C', 'C', 'D', 'B', 'C', 'A', 'D', 'E', 'E', 'E'] },
    ],
  },
  {
    title: 'Halk Hikâyeleri – Dede Korkut Hikâyeleri – Mesnevi',
    description: 'Halk hikâyeleri, Dede Korkut ve mesneviye ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'D', 'C', 'C', 'A', 'E', 'D', 'B', 'D', 'D'] },
      { title: 'Test 2', answers: ['E', 'D', 'E', 'B', 'B', 'C', 'A', 'C', 'A'] },
      { title: 'Test 3', answers: ['D', 'B', 'E', 'A', 'E', 'B', 'A', 'D'] },
      { title: 'Test 4', answers: ['E', 'B', 'D', 'A', 'B', 'C', 'A', 'D', 'D', 'A'] },
    ],
  },
  {
    title: "Tanzimat'tan Cumhuriyet Dönemi'ne Kadar Hikâye",
    description: "Tanzimat'tan Cumhuriyet'e kadar hikâyeye ait testler",
    tests: [
      { title: 'Test 1', answers: ['C', 'E', 'C', 'A', 'A', 'B', 'C', 'C', 'C', 'D', 'A', 'E'] },
      { title: 'Test 2', answers: ['C', 'B', 'B', 'D', 'D', 'D', 'C', 'D', 'C', 'D'] },
      { title: 'Test 3', answers: ['B', 'C', 'C', 'D', 'E', 'D', 'A', 'C', 'E', 'D'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Hikâye (Millî – Dinî Duyarlılığı Yansıtan Hikâyeler)",
    description: "Millî ve dinî duyarlılığı yansıtan cumhuriyet dönemi hikâyelerine ait testler",
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'E', 'B', 'D', 'C', 'A', 'B', 'C', 'E'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Hikâye (Modernist Hikâye)",
    description: "Modernist hikâyeye ait testler",
    tests: [
      { title: 'Test 1', answers: ['B', 'D', 'A', 'C', 'B', 'E', 'C', 'B'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Hikâye (Bireyin İç Dünyasını Yansıtan Hikâyeler)",
    description: "Bireyin iç dünyasını yansıtan hikâyelere ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'B', 'A', 'C', 'D', 'D', 'B', 'E', 'A', 'B'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Hikâye Karma Test",
    description: "Cumhuriyet dönemi hikâyesini kapsayan karma testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'A', 'B', 'C', 'E', 'C', 'A', 'E'] },
      { title: 'Test 2', answers: ['B', 'A', 'B', 'C', 'A', 'D', 'C', 'D', 'E'] },
      { title: 'Test 3', answers: ['B', 'E', 'D', 'E', 'B', 'A', 'E', 'E', 'A', 'A', 'C'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Hikâye (Toplumcu Gerçekçi Hikâye)",
    description: "Toplumcu gerçekçi hikâyeye ait testler",
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'C', 'E', 'E', 'D', 'D', 'E', 'D', 'C'] },
    ],
  },
  // ─── ROMAN ──────────────────────────────────────────────────────────────────
  {
    title: 'Roman (Tür Bilgisi)',
    description: 'Roman türüne ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'B', 'B', 'D', 'A', 'B', 'C', 'A', 'A'] },
      { title: 'Test 2', answers: ['B', 'D', 'C', 'E', 'C', 'E', 'D', 'C', 'E'] },
      { title: 'Test 3', answers: ['B', 'C', 'D', 'A', 'E', 'E', 'D', 'B'] },
      { title: 'Test 4', answers: ['D', 'E', 'C', 'A', 'E', 'A'] },
      { title: 'Test 5', answers: ['D', 'B', 'C', 'D', 'B', 'C', 'A'] },
    ],
  },
  {
    title: "Servetifünun Dönemi'nde Roman",
    description: "Servetifünun dönemi romanına ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'D', 'D', 'C', 'E', 'D', 'B', 'E', 'C'] },
      { title: 'Test 2', answers: ['C', 'A', 'C', 'C', 'B', 'C', 'E', 'A', 'B', 'B', 'C', 'C'] },
      { title: 'Test 3', answers: ['C', 'B', 'C', 'D', 'B', 'D', 'E', 'C', 'B', 'D', 'D', 'E'] },
    ],
  },
  {
    title: "Millî Edebiyat Dönemi'nde Roman",
    description: "Millî edebiyat dönemi romanına ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'A', 'C', 'D', 'B', 'E', 'E', 'C'] },
      { title: 'Test 2', answers: ['D', 'A', 'B', 'C', 'C', 'D', 'D', 'B', 'D', 'A', 'E', 'C'] },
      { title: 'Test 3', answers: ['C', 'D', 'E', 'D', 'C', 'C', 'D', 'D', 'E', 'A'] },
    ],
  },
  {
    title: "Tanzimat Dönemi'nde Roman",
    description: "Tanzimat dönemi romanına ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'E', 'D', 'B', 'C', 'C', 'B', 'B', 'D', 'A'] },
      { title: 'Test 2', answers: ['C', 'D', 'C', 'E', 'B', 'B', 'A', 'A', 'E'] },
      { title: 'Test 3', answers: ['C', 'D', 'C', 'A', 'B', 'A', 'E', 'D', 'D', 'C', 'C'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Roman (Millî ve Dinî Duyarlılığı Esas Alan Roman)",
    description: "Millî ve dinî duyarlılığı esas alan cumhuriyet dönemi romanına ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'B', 'E', 'C', 'D', 'A', 'B', 'E', 'C', 'D', 'B'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Roman (Bireyin İç Dünyasını Esas Alan Roman)",
    description: "Bireyin iç dünyasını esas alan cumhuriyet dönemi romanına ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'B', 'E', 'E', 'E', 'C', 'B', 'C', 'A', 'E', 'C'] },
      { title: 'Test 2', answers: ['D', 'E', 'D', 'E', 'A', 'C', 'E', 'E', 'D'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Roman (Toplumcu Gerçekçi Roman)",
    description: "Toplumcu gerçekçi cumhuriyet dönemi romanına ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'C', 'B', 'A', 'D', 'C', 'E', 'B'] },
      { title: 'Test 2', answers: ['C', 'A', 'D', 'E', 'D', 'C', 'A', 'B', 'C', 'C', 'E'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Roman (Modernizmi Esas Alan Roman)",
    description: "Modernizmi esas alan cumhuriyet dönemi romanına ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'E', 'D', 'C', 'A', 'B', 'D', 'D', 'E', 'A'] },
      { title: 'Test 2', answers: ['D', 'E', 'C', 'B', 'C', 'D', 'C', 'B', 'A', 'E', 'C'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Roman (1980 Sonrası Roman – Popüler Roman)",
    description: "1980 sonrası roman ve popüler romana ait testler",
    tests: [
      { title: 'Test 1', answers: ['B', 'E', 'A', 'C', 'D', 'E', 'C', 'B', 'E', 'D', 'A', 'B'] },
    ],
  },
  // ─── TİYATRO ────────────────────────────────────────────────────────────────
  {
    title: 'Tiyatro (Tür Bilgisi)',
    description: 'Tiyatro türüne ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'B', 'A', 'D', 'E', 'C', 'A', 'B', 'D', 'C'] },
      { title: 'Test 2', answers: ['D', 'A', 'C', 'D', 'C', 'E', 'C', 'B', 'C'] },
    ],
  },
  {
    title: 'Geleneksel Türk Tiyatrosu',
    description: 'Geleneksel Türk tiyatrosuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'D', 'D', 'A', 'E', 'C', 'A', 'B', 'C'] },
    ],
  },
  {
    title: "Tanzimat Dönemi'nde Tiyatro",
    description: "Tanzimat dönemi tiyatrosuna ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'B', 'A', 'E', 'C', 'C', 'C', 'D', 'A', 'E'] },
      { title: 'Test 2', answers: ['E', 'B', 'D', 'D', 'B', 'C', 'A', 'C', 'E', 'E'] },
    ],
  },
  {
    title: "Millî Edebiyat Dönemi'nde Tiyatro",
    description: "Millî edebiyat dönemi tiyatrosuna ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'A', 'C', 'E', 'B', 'E', 'E', 'C', 'A', 'D', 'C'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Tiyatro",
    description: "Cumhuriyet dönemi tiyatrosuna ait testler",
    tests: [
      { title: 'Test 1', answers: ['E', 'A', 'E', 'C', 'B', 'C', 'D', 'E', 'E', 'C'] },
      { title: 'Test 2', answers: ['A', 'C', 'B', 'E', 'D', 'C', 'E', 'E', 'D', 'E'] },
    ],
  },
  // ─── ÖĞRETİCİ METİNLER ──────────────────────────────────────────────────────
  {
    title: 'Öğretici Metinler',
    description: 'Öğretici metinlere ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'D', 'B', 'E', 'E', 'E', 'C', 'D', 'A', 'B'] },
      { title: 'Test 2', answers: ['C', 'B', 'D', 'B', 'C', 'C', 'E', 'B', 'E', 'E', 'A'] },
      { title: 'Test 3', answers: ['D', 'B', 'D', 'C', 'D', 'D', 'D', 'A', 'C', 'B', 'D', 'D'] },
      { title: 'Test 4', answers: ['B', 'E', 'B', 'E', 'E', 'E', 'B', 'D', 'E', 'C', 'B'] },
      { title: 'Test 5', answers: ['C', 'B', 'B', 'D', 'C', 'C', 'E', 'D', 'A', 'D'] },
      { title: 'Test 6', answers: ['D', 'B', 'B', 'B', 'B', 'D', 'E', 'A', 'D'] },
      { title: 'Test 7', answers: ['E', 'E', 'C', 'B', 'D', 'A', 'C', 'E', 'E', 'E'] },
    ],
  },
  {
    title: 'Divan Edebiyatında Nesir',
    description: 'Divan edebiyatında nesre ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'D', 'D', 'C', 'B', 'E', 'B', 'E', 'E', 'C', 'B', 'D'] },
    ],
  },
  {
    title: "Tanzimat'tan Cumhuriyet Dönemi'ne Kadar Öğretici Metinler",
    description: "Tanzimat'tan Cumhuriyet'e kadar öğretici metinlere ait testler",
    tests: [
      { title: 'Test 1', answers: ['C', 'D', 'C', 'B', 'B', 'B', 'B', 'C', 'A', 'E', 'D'] },
      { title: 'Test 2', answers: ['D', 'C', 'A', 'B', 'B', 'A', 'A', 'A', 'A', 'B', 'D'] },
      { title: 'Test 3', answers: ['C', 'C', 'E', 'A', 'B', 'D', 'E', 'D', 'C', 'E', 'E'] },
      { title: 'Test 4', answers: ['C', 'C', 'B', 'E', 'D', 'D', 'B', 'E', 'E', 'B', 'C', 'B'] },
    ],
  },
  {
    title: "Cumhuriyet Dönemi'nde Öğretici Metinler",
    description: "Cumhuriyet dönemi öğretici metinlerine ait testler",
    tests: [
      { title: 'Test 1', answers: ['D', 'C', 'A', 'B', 'C', 'E', 'C', 'B', 'C', 'E', 'A', 'E'] },
    ],
  },
  {
    title: 'Sözlü Anlatım',
    description: 'Sözlü anlatıma ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'E', 'A', 'A', 'C', 'D', 'C', 'A', 'E', 'B', 'C', 'D'] },
    ],
  },
  // ─── KARMA ──────────────────────────────────────────────────────────────────
  {
    title: 'Edebî Akımlar',
    description: 'Edebî akımlara ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'B', 'C', 'E', 'C', 'A', 'E', 'A', 'E', 'C', 'C', 'A', 'A', 'B'] },
      { title: 'Test 2', answers: ['B', 'C', 'D', 'D', 'E', 'D', 'B', 'B', 'E', 'A', 'C', 'B'] },
      { title: 'Test 3', answers: ['C', 'E', 'C', 'A', 'E', 'D', 'A', 'D', 'C', 'C', 'A', 'C', 'B'] },
      { title: 'Test 4', answers: ['C', 'C', 'B', 'E', 'C', 'E', 'D', 'C', 'B', 'C', 'B', 'B', 'E'] },
    ],
  },
  {
    title: 'Türkiye Dışı Çağdaş Türk Edebiyatı',
    description: 'Türkiye dışı çağdaş Türk edebiyatına ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'B', 'D', 'A', 'A', 'B', 'D', 'A', 'B', 'C', 'B'] },
      { title: 'Test 2', answers: ['A', 'E', 'E', 'E', 'A', 'C', 'C', 'A', 'B', 'E', 'E'] },
    ],
  },
];

async function main() {
  console.log('Seeding Edebiyat Soru Bankası - structure (sections, tests, questions)');

  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT/AYT Edebiyat konu bazlı soru bankası',
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
        description: 'TYT/AYT Edebiyat konu bazlı soru bankası',
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
          timeLimit: testData.answers.length * 72,
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
