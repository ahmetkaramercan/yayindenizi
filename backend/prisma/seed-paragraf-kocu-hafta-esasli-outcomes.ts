import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const BOOK_TITLE = 'Paragraf Koçu (Hafta Esaslı)';
const MAX_TEST_NO = 160;
type RawMapping = { testNo: number; questionNo: number; code: string };

const OUTCOMES: { code: string; name: string; category: string }[] = [
  { code: '21.5.4', name: 'Paragrafın Yorumlanması', category: 'Paragraf Anlam' },
  { code: '21.5.6', name: 'Paragrafın Konusu', category: 'Paragraf Anlam' },
  { code: '21.5.2', name: 'Paragrafta Yardımcı Düşünceler', category: 'Paragraf Anlam' },
  { code: '21.4.2', name: 'Paragrafta Boş Bırakılan Yerleri Tamamlama', category: 'Paragraf Yapısı' },
  { code: '21.3', name: 'Anlatım Teknikleri ve Düşünceyi Geliştirme Yolları', category: 'Paragraf' },
  { code: '21.5.1', name: 'Paragrafta Ana Düşünce (Ana Fikir)', category: 'Paragraf Anlam' },
  { code: '21.4.3', name: 'Paragrafta Anlatım Akışını Bozan Cümle', category: 'Paragraf Yapısı' },
  { code: '21.5.3', name: 'Paragrafın Karşılık Olduğu Soruyu Belirleme', category: 'Paragraf Anlam' },
  { code: '21.4.6', name: 'Paragrafta Cümlelerin Yerini Değiştirme', category: 'Paragraf Yapısı' },
  { code: '21.4.4', name: 'Paragrafa Cümle Yerleştirme', category: 'Paragraf Yapısı' },
  { code: '21.4.1', name: 'Paragrafı İkiye Ayırma', category: 'Paragraf Yapısı' },
  { code: '21.4.5', name: 'Cümlelerden Paragraf Oluşturma', category: 'Paragraf Yapısı' },
  { code: '21.5.10', name: 'Paragrafa Özgü Soru Kökü', category: 'Paragraf Anlam' },
];

// testNo (global 1-160) -> cevap anahtarı (A=0, B=1, C=2, D=3, E=4)
// Seviye i, yerel test j → globalTestNo = (i-1)*20 + j
const ANSWER_KEYS: { [testNo: number]: number[] } = {
  // === Seviye 1 (Test 1-20) ===
  1:   [3,0,4,2,0,4,1,2],   // DAECAEBC
  2:   [2,4,3,1,1,0,2],     // CEDBBAC
  3:   [4,2,0,1,3,1,2,4],   // ECABDBCE
  4:   [3,0,0,4,2,4,2,3],   // DAAECECD
  5:   [0,3,2,2,4,1,1,3],   // ADCCEBBD
  6:   [2,0,1,2,3,4,1,0],   // CABCDEBA
  7:   [0,3,4,1,2,2,4,3],   // ADEBCCED
  8:   [1,3,3,2,0,4,1,4],   // BDDCAEBE
  9:   [3,2,1,0,1,4,0],     // DCBABEA
  10:  [4,1,3,2,4,1,0,3],   // EBDCEBAD
  11:  [3,1,4,1,2,0,2],     // DBEBCAC
  12:  [2,0,0,3,3,1,4,2],   // CAADDBEC
  13:  [3,4,2,1,4,0,0,3],   // DECBEAAD
  14:  [2,1,3,4,0,3,2,1],   // CBDEADCB
  15:  [3,2,4,3,1,0,2],     // DCEDBAC
  16:  [3,3,1,0,2,4,0,2],   // DDBACEAC
  17:  [2,1,3,0,4,2,0,4],   // CBDAECAE
  18:  [3,4,1,1,3,0,0,4],   // DEBBDAAE
  19:  [3,1,2,4,0,2,4,0],   // DBCEACEA
  20:  [3,2,4,1,2,0,1,3],   // DCEBCABD
  // === Seviye 2 (Test 21-40) ===
  21:  [1,1,3,4,0,3,2],     // BBDEADC
  22:  [2,3,3,1,1,0,4,2],   // CDDBBAEC
  23:  [0,1,2,1,4,0,2,3],   // ABCBEACD
  24:  [3,4,2,3,1,0,2,4],   // DECDBACE
  25:  [4,4,2,3,0,1,0],     // EECDABA
  26:  [4,3,3,2,3,0,2],     // EDDCDAC
  27:  [3,4,1,1,4,0,2],     // DEBBEAC
  28:  [4,1,2,3,0,2,3,1],   // EBCDACDB
  29:  [2,1,0,2,3,4],       // CBACDE
  30:  [2,4,4,1,2,0,3,1],   // CEEBCADB
  31:  [2,1,3,4,0,1,2],     // CBDEABC
  32:  [2,4,1,2,0,1,4],     // CEBCABE
  33:  [3,2,3,4,1,0,0,3],   // DCDEBAAD
  34:  [1,2,1,4,2,3,4,0],   // BCBECDEA
  35:  [1,1,4,2,2,0,3,4],   // BBECCADE
  36:  [3,2,1,0,3,4],       // DCBADE
  37:  [3,3,1,0,4,0,2],     // DDBAEAC
  38:  [1,3,1,4,2,0,3],     // BDBECAD
  39:  [1,0,3,1,4,0,2],     // BADBEAC
  40:  [1,4,2,3,0,3],       // BECDAD
  // === Seviye 3 (Test 41-60) ===
  41:  [3,0,4,3,1,2],       // DAEDBC
  42:  [2,4,4,1,3,3,0],     // CEEBDDA
  43:  [4,3,2,3,1,0,4],     // EDCDBAE
  44:  [0,4,1,2,2,3,3,4],   // AEBCCDDE
  45:  [3,2,0,2,1,4,3],     // DCACBED
  46:  [3,0,4,0,1,3,2],     // DAEABDC
  47:  [2,0,1,3,4,3,2,0],   // CABDEDCA
  48:  [1,0,4,4,2,3],       // BAEECD
  49:  [1,0,0,4,3,2],       // BAAEDC
  50:  [2,1,0,1,4,3,2],     // CBABEDC
  51:  [1,2,3,0,4,2,1,4],   // BCDAECBE
  52:  [1,1,3,0,0,4,2,3],   // BBDAAECD
  53:  [4,0,1,2,3,0],       // EABCDA
  54:  [2,0,2,3,4,1,3],     // CACDEBD
  55:  [3,2,0,1,4,4,3],     // DCABEED
  56:  [3,2,4,3,1,4,0,0],   // DCEDBEAA
  57:  [1,2,3,0,0,3,4],     // BCDAADE
  58:  [2,1,0,4,3,1,0],     // CBAEDBA
  59:  [2,1,3,2,4,1,0],     // CBDCEBA
  60:  [4,1,2,3,0,4,2,3],   // EBCDAECD
  // === Seviye 4 (Test 61-80) ===
  61:  [0,2,0,3,3,4,1,4],   // ACADDEBE
  62:  [2,1,3,0,4,2,4,1],   // CBDAECEB
  63:  [2,3,0,4,2,3,1,1],   // CDAECDBB
  64:  [3,4,1,0,2,0],       // DEBACA
  65:  [3,3,0,2,1,2,0,4],   // DDACBCAE
  66:  [3,4,2,1,2,0,1,3],   // DECBCABD
  67:  [3,2,0,3,1,4,2],     // DCADBEC
  68:  [3,0,4,3,2,1,4],     // DAEDCBE
  69:  [1,2,2,4,0,3,3,1],   // BCCEADDB
  70:  [3,2,0,2,1,4,3],     // DCACBED
  71:  [4,1,1,3,1,0,3,2],   // EBBDBADC
  72:  [3,0,1,3,1,2,4],     // DABDBCE
  73:  [1,2,3,3,4,0,2],     // BCDDEAC
  74:  [3,1,0,1,3,2,4],     // DBABDCE
  75:  [4,3,0,0,4,2,3,1],   // EDAAECDB
  76:  [2,1,3,4,0,1,4,2],   // CBDEABEC
  77:  [2,0,4,3,0,1,2,3],   // CAEDABCD
  78:  [0,3,3,4,2,1,0,1],   // ADDECBAB
  79:  [2,4,3,2,1,4,1,0],   // CEDCBEBA
  80:  [4,2,3,4,1,3,2,0],   // ECDEBDCA
  // === Seviye 5 (Test 81-100) ===
  81:  [0,4,4,1,3,1,2,3],   // AEEBDBCD
  82:  [0,4,3,1,1,2,2,3],   // AEDBBCCD
  83:  [4,4,1,0,2,3,1,2],   // EEBACDBC
  84:  [4,2,0,2,4,4,3,0],   // ECACEEDA
  85:  [2,0,2,4,3,1,0,1],   // CACEDBAB
  86:  [3,0,3,2,1,2,4,0],   // DADCBCEA
  87:  [4,1,0,3,3,0,2],     // EBADDAC
  88:  [0,3,4,1,4,1,3,2],   // ADEBEBDC
  89:  [3,0,1,4,2,3,2,0],   // DABECDCA
  90:  [2,1,4,4,0,3,3],     // CBEEADD
  91:  [4,3,0,2,1,1,4,2],   // EDACBBEC
  92:  [3,0,1,2,2,0,4,1],   // DABCCAEB
  93:  [0,2,3,4,1,0,1,2],   // ACDEBABC
  94:  [0,1,2,3,3,1,4],     // ABCDDBE
  95:  [1,2,0,4,0,2,1,3],   // BCAEACBD
  96:  [3,4,4,3,2,2,4,0],   // DEEDCCEA
  97:  [3,1,2,2,1,3,4,0],   // DBCCBDEA
  98:  [0,4,1,1,2,3],       // AEBBCD
  99:  [1,0,1,3,3,2,4,2],   // BABDDCEC
  100: [1,2,0,1,4,2,0],     // BCABECA
  // === Seviye 6 (Test 101-120) ===
  101: [2,1,1,2,0,4,3],     // CBBCAED
  102: [2,1,3,1,2,3,4,0],   // CBDBCDEA
  103: [0,3,3,4,2,1,4,0],   // ADDECBEA
  104: [1,3,4,2,0,2,3,0],   // BDECACDA
  105: [2,0,2,3,0,3,4,4],   // CACDADEE
  106: [1,2,3,4,4,3,0],     // BCDEEDA
  107: [0,4,3,1,2,1,3,0],   // AEDBCBDA
  108: [1,3,0,4,2,3],       // BDAECD
  109: [2,2,1,3,1,3,0,4],   // CCBDBDAE
  110: [4,0,1,1,1,3,1,2],   // EABBBDBC
  111: [2,2,1,3,0,4,4],     // CCBDAEE
  112: [2,0,1,3,4,1,0,4],   // CABDEBAE
  113: [3,4,3,2,0,2,0,1],   // DEDCACAB
  114: [1,3,2,0,2,4,3,4],   // BDCACEDE
  115: [3,1,0,2,4,3,0],     // DBACEDA
  116: [2,4,1,2,3,0,0,4],   // CEBCDAAE
  117: [1,3,4,3,4,1,0,2],   // BDEDEBAC
  118: [0,2,4,1,3,4],       // ACEBDE
  119: [2,2,1,4,3,0,3,0],   // CCBEDADA
  120: [1,0,3,2,3,4,2],     // BADCDEC
  // === Seviye 7 (Test 121-140) ===
  121: [1,2,3,3,0,2,3],     // BCDDACD
  122: [0,4,1,2,2,3],       // AEBCCD
  123: [3,4,2,1,0,1,4,2],   // DECBABEC
  124: [0,2,3,4,1,4,1,3],   // ACDEBEBD
  125: [2,0,1,3,2,1,3,4],   // CABDCBDE
  126: [1,4,0,3,3,1,2,4],   // BEADDBCE
  127: [2,3,2,1,1,0,4],     // CDCBBAE
  128: [4,4,0,2,3,1,1,2],   // EEACDBBC
  129: [0,2,3,1,3,4,4,2],   // ACDBDEEC
  130: [2,3,4,3,4,2,1],     // CDEDECB
  131: [0,4,4,3,1,2,0,2],   // AEEDBCAC
  132: [2,4,0,3,1,2,1],     // CEADBCB
  133: [2,1,4,3,3,0,0],     // CBEDDAA
  134: [1,3,1,2,0,4,1,0],   // BDBCAEBA
  135: [4,0,1,3,2,2,1,0],   // EABDCCBA
  136: [0,0,2,4,3,2,1,3,4], // AACEDCBDE
  137: [0,2,4,1,2,4,3],     // ACEBCED
  138: [0,3,1,0,1,2,4],     // ADBABCE
  139: [1,0,2,4,2,4,3],     // BACECED
  140: [1,3,4,1,4,2,0],     // BDEBECA
  // === Seviye 8 (Test 141-160) ===
  141: [1,2,3,0,0,3,2,4],   // BCDAADCE
  142: [2,0,3,4,0,4,2,1],   // CADEAECB
  143: [1,3,3,4,0,2,1],     // BDDEACB
  144: [4,0,4,1,1,2,3,2],   // EAEBBCDC
  145: [0,0,3,2,3,1,4],     // AADCDBE
  146: [3,2,2,0,1,4,3,4],   // DCCABEDE
  147: [2,0,4,1,1,3,0,2],   // CAEBBDAC
  148: [3,4,4,1,3,3,0],     // DEEBDDA
  149: [4,1,0,4,3,1,1,2],   // EBAEDBBC
  150: [0,1,4,3,2,3,3],     // ABEDCDD
  151: [4,0,0,1,2,3,3],     // EAABCDD
  152: [1,1,4,2,2,0,3,1],   // BBECCADB
  153: [1,2,0,4,4,1,3],     // BCAEEBD
  154: [4,1,2,4,1,3,0,2],   // EBCEBDAC
  155: [3,1,1,2,0,2,3],     // DBBCACD
  156: [0,2,1,0,3,2,0,4],   // ACBADCAE
  157: [3,4,4,0,1,2,2],     // DEEABCC
  158: [4,3,3,2,2,0,1],     // EDDCCAB
  159: [3,3,2,0,1,2,0,4],   // DDCABCAE
  160: [0,0,4,4,1,1,3,2],   // AAEEBBDC
};

const RAW_MAPPINGS: RawMapping[] = [
  { testNo: 1, questionNo: 1, code: '21.5.4' },
  { testNo: 1, questionNo: 2, code: '21.5.6' },
  { testNo: 1, questionNo: 3, code: '21.5.2' },
  { testNo: 1, questionNo: 4, code: '21.5.4' },
  { testNo: 1, questionNo: 5, code: '21.4.2' },
  { testNo: 1, questionNo: 6, code: '21.3' },
  { testNo: 1, questionNo: 7, code: '21.5.2' },
  { testNo: 1, questionNo: 8, code: '21.5.6' },
  { testNo: 2, questionNo: 1, code: '21.5.2' },
  { testNo: 2, questionNo: 2, code: '21.5.1' },
  { testNo: 2, questionNo: 3, code: '21.5.2' },
  { testNo: 2, questionNo: 4, code: '21.4.3' },
  { testNo: 2, questionNo: 5, code: '21.5.3' },
  { testNo: 2, questionNo: 6, code: '21.5.1' },
  { testNo: 2, questionNo: 7, code: '21.4.2' },
  { testNo: 3, questionNo: 1, code: '21.5.2' },
  { testNo: 3, questionNo: 2, code: '21.5.1' },
  { testNo: 3, questionNo: 3, code: '21.5.6' },
  { testNo: 3, questionNo: 4, code: '21.5.6' },
  { testNo: 3, questionNo: 5, code: '21.3' },
  { testNo: 3, questionNo: 6, code: '21.4.6' },
  { testNo: 3, questionNo: 7, code: '21.4.4' },
  { testNo: 3, questionNo: 8, code: '21.5.2' },
  { testNo: 4, questionNo: 1, code: '21.4.1' },
  { testNo: 4, questionNo: 2, code: '21.5.6' },
  { testNo: 4, questionNo: 3, code: '21.4.2' },
  { testNo: 4, questionNo: 4, code: '21.5.2' },
  { testNo: 4, questionNo: 5, code: '21.3' },
  { testNo: 4, questionNo: 6, code: '21.5.2' },
  { testNo: 4, questionNo: 7, code: '21.5.2' },
  { testNo: 4, questionNo: 8, code: '21.5.1' },
  { testNo: 5, questionNo: 1, code: '21.5.6' },
  { testNo: 5, questionNo: 2, code: '21.5.2' },
  { testNo: 5, questionNo: 3, code: '21.4.5' },
  { testNo: 5, questionNo: 4, code: '21.4.4' },
  { testNo: 5, questionNo: 5, code: '21.5.1' },
  { testNo: 5, questionNo: 6, code: '21.5.2' },
  { testNo: 5, questionNo: 7, code: '21.5.1' },
  { testNo: 5, questionNo: 8, code: '21.4.2' },
  { testNo: 6, questionNo: 1, code: '21.3' },
  { testNo: 6, questionNo: 2, code: '21.4.2' },
  { testNo: 6, questionNo: 3, code: '21.5.6' },
  { testNo: 6, questionNo: 4, code: '21.4.1' },
  { testNo: 6, questionNo: 5, code: '21.5.4' },
  { testNo: 6, questionNo: 6, code: '21.5.1' },
  { testNo: 6, questionNo: 7, code: '21.5.1' },
  { testNo: 6, questionNo: 8, code: '21.5.2' },
  { testNo: 7, questionNo: 1, code: '21.4.4' },
  { testNo: 7, questionNo: 2, code: '21.5.1' },
  { testNo: 7, questionNo: 3, code: '21.4.5' },
  { testNo: 7, questionNo: 4, code: '21.5.6' },
  { testNo: 7, questionNo: 5, code: '21.5.2' },
  { testNo: 7, questionNo: 6, code: '21.5.1' },
  { testNo: 7, questionNo: 7, code: '21.3' },
  { testNo: 7, questionNo: 8, code: '21.5.1' },
  { testNo: 8, questionNo: 1, code: '21.3' },
  { testNo: 8, questionNo: 2, code: '21.4.2' },
  { testNo: 8, questionNo: 3, code: '21.4.3' },
  { testNo: 8, questionNo: 4, code: '21.5.1' },
  { testNo: 8, questionNo: 5, code: '21.5.6' },
  { testNo: 8, questionNo: 6, code: '21.5.2' },
  { testNo: 8, questionNo: 7, code: '21.5.3' },
  { testNo: 8, questionNo: 8, code: '21.5.2' },
  { testNo: 9, questionNo: 1, code: '21.5.1' },
  { testNo: 9, questionNo: 2, code: '21.4.5' },
  { testNo: 9, questionNo: 3, code: '21.4.1' },
  { testNo: 9, questionNo: 4, code: '21.5.2' },
  { testNo: 9, questionNo: 5, code: '21.4.2' },
  { testNo: 9, questionNo: 6, code: '21.5.2' },
  { testNo: 9, questionNo: 7, code: '21.5.1' },
  { testNo: 10, questionNo: 1, code: '21.5.4' },
  { testNo: 10, questionNo: 2, code: '21.4.4' },
  { testNo: 10, questionNo: 3, code: '21.4.3' },
  { testNo: 10, questionNo: 4, code: '21.5.2' },
  { testNo: 10, questionNo: 5, code: '21.5.2' },
  { testNo: 10, questionNo: 6, code: '21.5.1' },
  { testNo: 10, questionNo: 7, code: '21.5.10' },
  { testNo: 10, questionNo: 8, code: '21.4.2' },
  { testNo: 11, questionNo: 1, code: '21.5.4' },
  { testNo: 11, questionNo: 2, code: '21.4.6' },
  { testNo: 11, questionNo: 3, code: '21.5.1' },
  { testNo: 11, questionNo: 4, code: '21.4.1' },
  { testNo: 11, questionNo: 5, code: '21.5.2' },
  { testNo: 11, questionNo: 6, code: '21.4.2' },
  { testNo: 11, questionNo: 7, code: '21.4.2' },
  { testNo: 12, questionNo: 1, code: '21.4.3' },
  { testNo: 12, questionNo: 2, code: '21.5.2' },
  { testNo: 12, questionNo: 3, code: '21.4.2' },
  { testNo: 12, questionNo: 4, code: '21.3' },
  { testNo: 12, questionNo: 5, code: '21.5.1' },
  { testNo: 12, questionNo: 6, code: '21.5.6' },
  { testNo: 12, questionNo: 7, code: '21.5.4' },
  { testNo: 12, questionNo: 8, code: '21.5.2' },
  { testNo: 13, questionNo: 1, code: '21.5.4' },
  { testNo: 13, questionNo: 2, code: '21.5.4' },
  { testNo: 13, questionNo: 3, code: '21.4.1' },
  { testNo: 13, questionNo: 4, code: '21.5.6' },
  { testNo: 13, questionNo: 5, code: '21.4.5' },
  { testNo: 13, questionNo: 6, code: '21.5.1' },
  { testNo: 13, questionNo: 7, code: '21.5.1' },
  { testNo: 13, questionNo: 8, code: '21.5.1' },
  { testNo: 14, questionNo: 1, code: '21.5.2' },
  { testNo: 14, questionNo: 2, code: '21.4.2' },
  { testNo: 14, questionNo: 3, code: '21.3' },
  { testNo: 14, questionNo: 4, code: '21.5.2' },
  { testNo: 14, questionNo: 5, code: '21.5.6' },
  { testNo: 14, questionNo: 6, code: '21.4.3' },
  { testNo: 14, questionNo: 7, code: '21.5.1' },
  { testNo: 14, questionNo: 8, code: '21.5.2' },
  { testNo: 15, questionNo: 1, code: '21.4.1' },
  { testNo: 15, questionNo: 2, code: '21.5.1' },
  { testNo: 15, questionNo: 3, code: '21.5.2' },
  { testNo: 15, questionNo: 4, code: '21.5.4' },
  { testNo: 15, questionNo: 5, code: '21.4.2' },
  { testNo: 15, questionNo: 6, code: '21.5.1' },
  { testNo: 15, questionNo: 7, code: '21.4.2' },
  { testNo: 16, questionNo: 1, code: '21.4.6' },
  { testNo: 16, questionNo: 2, code: '21.5.1' },
  { testNo: 16, questionNo: 3, code: '21.5.1' },
  { testNo: 16, questionNo: 4, code: '21.4.2' },
  { testNo: 16, questionNo: 5, code: '21.5.2' },
  { testNo: 16, questionNo: 6, code: '21.5.4' },
  { testNo: 16, questionNo: 7, code: '21.5.1' },
  { testNo: 16, questionNo: 8, code: '21.4.1' },
  { testNo: 17, questionNo: 1, code: '21.4.3' },
  { testNo: 17, questionNo: 2, code: '21.5.4' },
  { testNo: 17, questionNo: 3, code: '21.4.1' },
  { testNo: 17, questionNo: 4, code: '21.5.2' },
  { testNo: 17, questionNo: 5, code: '21.4.2' },
  { testNo: 17, questionNo: 6, code: '21.5.2' },
  { testNo: 17, questionNo: 7, code: '21.5.4' },
  { testNo: 17, questionNo: 8, code: '21.5.2' },
  { testNo: 18, questionNo: 1, code: '21.4.3' },
  { testNo: 18, questionNo: 2, code: '21.5.2' },
  { testNo: 18, questionNo: 3, code: '21.4.6' },
  { testNo: 18, questionNo: 4, code: '21.5.6' },
  { testNo: 18, questionNo: 5, code: '21.4.4' },
  { testNo: 18, questionNo: 6, code: '21.5.2' },
  { testNo: 18, questionNo: 7, code: '21.5.6' },
  { testNo: 18, questionNo: 8, code: '21.3' },
  { testNo: 19, questionNo: 1, code: '21.4.4' },
  { testNo: 19, questionNo: 2, code: '21.5.2' },
  { testNo: 19, questionNo: 3, code: '21.4.1' },
  { testNo: 19, questionNo: 4, code: '21.5.1' },
  { testNo: 19, questionNo: 5, code: '21.5.6' },
  { testNo: 19, questionNo: 6, code: '21.5.2' },
  { testNo: 19, questionNo: 7, code: '21.5.2' },
  { testNo: 19, questionNo: 8, code: '21.4.2' },
  { testNo: 20, questionNo: 1, code: '21.4.3' },
  { testNo: 20, questionNo: 2, code: '21.5.2' },
  { testNo: 20, questionNo: 3, code: '21.4.2' },
  { testNo: 20, questionNo: 4, code: '21.5.1' },
  { testNo: 20, questionNo: 5, code: '21.5.4' },
  { testNo: 20, questionNo: 6, code: '21.4.6' },
  { testNo: 20, questionNo: 7, code: '21.4.2' },
  { testNo: 20, questionNo: 8, code: '21.5.1' },
  { testNo: 21, questionNo: 1, code: '21.5.2' },
  { testNo: 21, questionNo: 2, code: '21.4.2' },
  { testNo: 21, questionNo: 3, code: '21.5.4' },
  { testNo: 21, questionNo: 4, code: '21.5.2' },
  { testNo: 21, questionNo: 5, code: '21.4.2' },
  { testNo: 21, questionNo: 6, code: '21.5.1' },
  { testNo: 21, questionNo: 7, code: '21.5.4' },
  { testNo: 22, questionNo: 1, code: '21.4.4' },
  { testNo: 22, questionNo: 2, code: '21.5.6' },
  { testNo: 22, questionNo: 3, code: '21.4.5' },
  { testNo: 22, questionNo: 4, code: '21.5.2' },
  { testNo: 22, questionNo: 5, code: '21.4.1' },
  { testNo: 22, questionNo: 6, code: '21.3' },
  { testNo: 22, questionNo: 7, code: '21.5.1' },
  { testNo: 22, questionNo: 8, code: '21.5.2' },
  { testNo: 23, questionNo: 1, code: '21.5.4' },
  { testNo: 23, questionNo: 2, code: '21.5.6' },
  { testNo: 23, questionNo: 3, code: '21.4.2' },
  { testNo: 23, questionNo: 4, code: '21.5.1' },
  { testNo: 23, questionNo: 5, code: '21.5.4' },
  { testNo: 23, questionNo: 6, code: '21.5.6' },
  { testNo: 23, questionNo: 7, code: '21.4.3' },
  { testNo: 23, questionNo: 8, code: '21.5.2' },
  { testNo: 24, questionNo: 1, code: '21.4.4' },
  { testNo: 24, questionNo: 2, code: '21.5.6' },
  { testNo: 24, questionNo: 3, code: '21.5.2' },
  { testNo: 24, questionNo: 4, code: '21.4.1' },
  { testNo: 24, questionNo: 5, code: '21.4.2' },
  { testNo: 24, questionNo: 6, code: '21.5.6' },
  { testNo: 24, questionNo: 7, code: '21.5.2' },
  { testNo: 24, questionNo: 8, code: '21.3' },
  { testNo: 25, questionNo: 1, code: '21.4.5' },
  { testNo: 25, questionNo: 2, code: '21.5.2' },
  { testNo: 25, questionNo: 3, code: '21.4.3' },
  { testNo: 25, questionNo: 4, code: '21.5.2' },
  { testNo: 25, questionNo: 5, code: '21.5.4' },
  { testNo: 25, questionNo: 6, code: '21.5.2' },
  { testNo: 25, questionNo: 7, code: '21.4.4' },
  { testNo: 26, questionNo: 1, code: '21.5.1' },
  { testNo: 26, questionNo: 2, code: '21.4.1' },
  { testNo: 26, questionNo: 3, code: '21.5.2' },
  { testNo: 26, questionNo: 4, code: '21.3' },
  { testNo: 26, questionNo: 5, code: '21.4.2' },
  { testNo: 26, questionNo: 6, code: '21.5.2' },
  { testNo: 26, questionNo: 7, code: '21.5.4' },
  { testNo: 27, questionNo: 1, code: '21.5.2' },
  { testNo: 27, questionNo: 2, code: '21.4.6' },
  { testNo: 27, questionNo: 3, code: '21.4.2' },
  { testNo: 27, questionNo: 4, code: '21.4.4' },
  { testNo: 27, questionNo: 5, code: '21.5.4' },
  { testNo: 27, questionNo: 6, code: '21.5.4' },
  { testNo: 27, questionNo: 7, code: '21.5.2' },
  { testNo: 28, questionNo: 1, code: '21.5.3' },
  { testNo: 28, questionNo: 2, code: '21.5.2' },
  { testNo: 28, questionNo: 3, code: '21.4.1' },
  { testNo: 28, questionNo: 4, code: '21.5.2' },
  { testNo: 28, questionNo: 5, code: '21.5.4' },
  { testNo: 28, questionNo: 6, code: '21.5.1' },
  { testNo: 28, questionNo: 7, code: '21.5.2' },
  { testNo: 28, questionNo: 8, code: '21.5.2' },
  { testNo: 29, questionNo: 1, code: '21.4.5' },
  { testNo: 29, questionNo: 2, code: '21.4.2' },
  { testNo: 29, questionNo: 3, code: '21.5.1' },
  { testNo: 29, questionNo: 4, code: '21.3' },
  { testNo: 29, questionNo: 5, code: '21.5.1' },
  { testNo: 29, questionNo: 6, code: '21.5.1' },
  { testNo: 30, questionNo: 1, code: '21.4.3' },
  { testNo: 30, questionNo: 2, code: '21.5.2' },
  { testNo: 30, questionNo: 3, code: '21.4.2' },
  { testNo: 30, questionNo: 4, code: '21.5.4' },
  { testNo: 30, questionNo: 5, code: '21.5.2' },
  { testNo: 30, questionNo: 6, code: '21.5.6' },
  { testNo: 30, questionNo: 7, code: '21.5.2' },
  { testNo: 30, questionNo: 8, code: '21.5.4' },
  { testNo: 31, questionNo: 1, code: '21.5.2' },
  { testNo: 31, questionNo: 2, code: '21.4.5' },
  { testNo: 31, questionNo: 3, code: '21.4.4' },
  { testNo: 31, questionNo: 4, code: '21.5.4' },
  { testNo: 31, questionNo: 5, code: '21.5.2' },
  { testNo: 31, questionNo: 6, code: '21.5.2' },
  { testNo: 31, questionNo: 7, code: '21.5.1' },
  { testNo: 32, questionNo: 1, code: '21.4.1' },
  { testNo: 32, questionNo: 2, code: '21.4.2' },
  { testNo: 32, questionNo: 3, code: '21.5.3' },
  { testNo: 32, questionNo: 4, code: '21.5.2' },
  { testNo: 32, questionNo: 5, code: '21.5.1' },
  { testNo: 32, questionNo: 6, code: '21.5.1' },
  { testNo: 32, questionNo: 7, code: '21.5.1' },
  { testNo: 33, questionNo: 1, code: '21.4.1' },
  { testNo: 33, questionNo: 2, code: '21.5.4' },
  { testNo: 33, questionNo: 3, code: '21.4.2' },
  { testNo: 33, questionNo: 4, code: '21.5.2' },
  { testNo: 33, questionNo: 5, code: '21.5.6' },
  { testNo: 33, questionNo: 6, code: '21.5.4' },
  { testNo: 33, questionNo: 7, code: '21.5.6' },
  { testNo: 33, questionNo: 8, code: '21.5.2' },
  { testNo: 34, questionNo: 1, code: '21.4.3' },
  { testNo: 34, questionNo: 2, code: '21.5.2' },
  { testNo: 34, questionNo: 3, code: '21.4.5' },
  { testNo: 34, questionNo: 4, code: '21.3' },
  { testNo: 34, questionNo: 5, code: '21.5.1' },
  { testNo: 34, questionNo: 6, code: '21.4.1' },
  { testNo: 34, questionNo: 7, code: '21.5.2' },
  { testNo: 34, questionNo: 8, code: '21.5.6' },
  { testNo: 35, questionNo: 1, code: '21.4.4' },
  { testNo: 35, questionNo: 2, code: '21.5.4' },
  { testNo: 35, questionNo: 3, code: '21.5.6' },
  { testNo: 35, questionNo: 4, code: '21.5.4' },
  { testNo: 35, questionNo: 5, code: '21.4.2' },
  { testNo: 35, questionNo: 6, code: '21.5.2' },
  { testNo: 35, questionNo: 7, code: '21.3' },
  { testNo: 35, questionNo: 8, code: '21.5.6' },
  { testNo: 36, questionNo: 1, code: '21.4.2' },
  { testNo: 36, questionNo: 2, code: '21.5.2' },
  { testNo: 36, questionNo: 3, code: '21.5.1' },
  { testNo: 36, questionNo: 4, code: '21.5.3' },
  { testNo: 36, questionNo: 5, code: '21.5.2' },
  { testNo: 36, questionNo: 6, code: '21.3' },
  { testNo: 37, questionNo: 1, code: '21.4.1' },
  { testNo: 37, questionNo: 2, code: '21.5.4' },
  { testNo: 37, questionNo: 3, code: '21.4.3' },
  { testNo: 37, questionNo: 4, code: '21.5.1' },
  { testNo: 37, questionNo: 5, code: '21.5.2' },
  { testNo: 37, questionNo: 6, code: '21.5.6' },
  { testNo: 37, questionNo: 7, code: '21.5.2' },
  { testNo: 38, questionNo: 1, code: '21.4.5' },
  { testNo: 38, questionNo: 2, code: '21.4.2' },
  { testNo: 38, questionNo: 3, code: '21.3' },
  { testNo: 38, questionNo: 4, code: '21.5.4' },
  { testNo: 38, questionNo: 5, code: '21.4.1' },
  { testNo: 38, questionNo: 6, code: '21.5.1' },
  { testNo: 38, questionNo: 7, code: '21.5.2' },
  { testNo: 39, questionNo: 1, code: '21.5.3' },
  { testNo: 39, questionNo: 2, code: '21.5.1' },
  { testNo: 39, questionNo: 3, code: '21.4.2' },
  { testNo: 39, questionNo: 4, code: '21.5.2' },
  { testNo: 39, questionNo: 5, code: '21.5.2' },
  { testNo: 39, questionNo: 6, code: '21.5.1' },
  { testNo: 39, questionNo: 7, code: '21.5.4' },
  { testNo: 40, questionNo: 1, code: '21.4.6' },
  { testNo: 40, questionNo: 2, code: '21.4.2' },
  { testNo: 40, questionNo: 3, code: '21.5.2' },
  { testNo: 40, questionNo: 4, code: '21.5.2' },
  { testNo: 40, questionNo: 5, code: '21.5.6' },
  { testNo: 40, questionNo: 6, code: '21.5.2' },
  { testNo: 41, questionNo: 1, code: '21.4.3' },
  { testNo: 41, questionNo: 2, code: '21.5.2' },
  { testNo: 41, questionNo: 3, code: '21.3' },
  { testNo: 41, questionNo: 4, code: '21.4.1' },
  { testNo: 41, questionNo: 5, code: '21.5.2' },
  { testNo: 41, questionNo: 6, code: '21.5.1' },
  { testNo: 42, questionNo: 1, code: '21.5.2' },
  { testNo: 42, questionNo: 2, code: '21.4.1' },
  { testNo: 42, questionNo: 3, code: '21.5.3' },
  { testNo: 42, questionNo: 4, code: '21.4.2' },
  { testNo: 42, questionNo: 5, code: '21.5.1' },
  { testNo: 42, questionNo: 6, code: '21.5.1' },
  { testNo: 42, questionNo: 7, code: '21.5.4' },
  { testNo: 43, questionNo: 1, code: '21.5.2' },
  { testNo: 43, questionNo: 2, code: '21.4.3' },
  { testNo: 43, questionNo: 3, code: '21.4.2' },
  { testNo: 43, questionNo: 4, code: '21.5.1' },
  { testNo: 43, questionNo: 5, code: '21.5.2' },
  { testNo: 43, questionNo: 6, code: '21.5.4' },
  { testNo: 43, questionNo: 7, code: '21.5.2' },
  { testNo: 44, questionNo: 1, code: '21.4.4' },
  { testNo: 44, questionNo: 2, code: '21.5.1' },
  { testNo: 44, questionNo: 3, code: '21.5.2' },
  { testNo: 44, questionNo: 4, code: '21.4.5' },
  { testNo: 44, questionNo: 5, code: '21.5.4' },
  { testNo: 44, questionNo: 6, code: '21.5.6' },
  { testNo: 44, questionNo: 7, code: '21.5.2' },
  { testNo: 44, questionNo: 8, code: '21.5.4' },
  { testNo: 45, questionNo: 1, code: '21.4.5' },
  { testNo: 45, questionNo: 2, code: '21.5.6' },
  { testNo: 45, questionNo: 3, code: '21.4.2' },
  { testNo: 45, questionNo: 4, code: '21.5.4' },
  { testNo: 45, questionNo: 5, code: '21.5.2' },
  { testNo: 45, questionNo: 6, code: '21.5.4' },
  { testNo: 45, questionNo: 7, code: '21.5.4' },
  { testNo: 46, questionNo: 1, code: '21.4.5' },
  { testNo: 46, questionNo: 2, code: '21.5.1' },
  { testNo: 46, questionNo: 3, code: '21.3' },
  { testNo: 46, questionNo: 4, code: '21.5.4' },
  { testNo: 46, questionNo: 5, code: '21.5.1' },
  { testNo: 46, questionNo: 6, code: '21.5.2' },
  { testNo: 46, questionNo: 7, code: '21.5.1' },
  { testNo: 47, questionNo: 1, code: '21.4.3' },
  { testNo: 47, questionNo: 2, code: '21.5.4' },
  { testNo: 47, questionNo: 3, code: '21.4.2' },
  { testNo: 47, questionNo: 4, code: '21.5.4' },
  { testNo: 47, questionNo: 5, code: '21.5.2' },
  { testNo: 47, questionNo: 6, code: '21.5.2' },
  { testNo: 47, questionNo: 7, code: '21.5.1' },
  { testNo: 47, questionNo: 8, code: '21.5.6' },
  { testNo: 48, questionNo: 1, code: '21.4.4' },
  { testNo: 48, questionNo: 2, code: '21.5.6' },
  { testNo: 48, questionNo: 3, code: '21.4.2' },
  { testNo: 48, questionNo: 4, code: '21.5.2' },
  { testNo: 48, questionNo: 5, code: '21.5.2' },
  { testNo: 48, questionNo: 6, code: '21.5.1' },
  { testNo: 49, questionNo: 1, code: '21.4.6' },
  { testNo: 49, questionNo: 2, code: '21.5.1' },
  { testNo: 49, questionNo: 3, code: '21.4.2' },
  { testNo: 49, questionNo: 4, code: '21.5.2' },
  { testNo: 49, questionNo: 5, code: '21.4.1' },
  { testNo: 49, questionNo: 6, code: '21.5.2' },
  { testNo: 50, questionNo: 1, code: '21.4.3' },
  { testNo: 50, questionNo: 2, code: '21.4.2' },
  { testNo: 50, questionNo: 3, code: '21.5.1' },
  { testNo: 50, questionNo: 4, code: '21.5.4' },
  { testNo: 50, questionNo: 5, code: '21.5.6' },
  { testNo: 50, questionNo: 6, code: '21.5.2' },
  { testNo: 50, questionNo: 7, code: '21.5.2' },
  { testNo: 51, questionNo: 1, code: '21.5.1' },
  { testNo: 51, questionNo: 2, code: '21.5.4' },
  { testNo: 51, questionNo: 3, code: '21.4.3' },
  { testNo: 51, questionNo: 4, code: '21.4.2' },
  { testNo: 51, questionNo: 5, code: '21.5.2' },
  { testNo: 51, questionNo: 6, code: '21.5.6' },
  { testNo: 51, questionNo: 7, code: '21.4.1' },
  { testNo: 51, questionNo: 8, code: '21.5.2' },
  { testNo: 52, questionNo: 1, code: '21.4.6' },
  { testNo: 52, questionNo: 2, code: '21.5.2' },
  { testNo: 52, questionNo: 3, code: '21.3' },
  { testNo: 52, questionNo: 4, code: '21.5.1' },
  { testNo: 52, questionNo: 5, code: '21.5.1' },
  { testNo: 52, questionNo: 6, code: '21.5.2' },
  { testNo: 52, questionNo: 7, code: '21.5.6' },
  { testNo: 52, questionNo: 8, code: '21.4.2' },
  { testNo: 53, questionNo: 1, code: '21.5.2' },
  { testNo: 53, questionNo: 2, code: '21.4.4' },
  { testNo: 53, questionNo: 3, code: '21.5.10' },
  { testNo: 53, questionNo: 4, code: '21.5.1' },
  { testNo: 53, questionNo: 5, code: '21.4.2' },
  { testNo: 53, questionNo: 6, code: '21.5.1' },
  { testNo: 54, questionNo: 1, code: '21.4.3' },
  { testNo: 54, questionNo: 2, code: '21.5.4' },
  { testNo: 54, questionNo: 3, code: '21.5.3' },
  { testNo: 54, questionNo: 4, code: '21.4.5' },
  { testNo: 54, questionNo: 5, code: '21.5.2' },
  { testNo: 54, questionNo: 6, code: '21.5.4' },
  { testNo: 54, questionNo: 7, code: '21.5.2' },
  { testNo: 55, questionNo: 1, code: '21.4.1' },
  { testNo: 55, questionNo: 2, code: '21.5.6' },
  { testNo: 55, questionNo: 3, code: '21.4.2' },
  { testNo: 55, questionNo: 4, code: '21.5.2' },
  { testNo: 55, questionNo: 5, code: '21.5.6' },
  { testNo: 55, questionNo: 6, code: '21.5.2' },
  { testNo: 55, questionNo: 7, code: '21.3' },
  { testNo: 56, questionNo: 1, code: '21.4.1' },
  { testNo: 56, questionNo: 2, code: '21.5.2' },
  { testNo: 56, questionNo: 3, code: '21.5.1' },
  { testNo: 56, questionNo: 4, code: '21.5.1' },
  { testNo: 56, questionNo: 5, code: '21.5.1' },
  { testNo: 56, questionNo: 6, code: '21.5.2' },
  { testNo: 56, questionNo: 7, code: '21.5.3' },
  { testNo: 56, questionNo: 8, code: '21.4.6' },
  { testNo: 57, questionNo: 1, code: '21.4.2' },
  { testNo: 57, questionNo: 2, code: '21.4.3' },
  { testNo: 57, questionNo: 3, code: '21.5.2' },
  { testNo: 57, questionNo: 4, code: '21.5.1' },
  { testNo: 57, questionNo: 5, code: '21.4.5' },
  { testNo: 57, questionNo: 6, code: '21.5.2' },
  { testNo: 57, questionNo: 7, code: '21.5.1' },
  { testNo: 58, questionNo: 1, code: '21.4.2' },
  { testNo: 58, questionNo: 2, code: '21.4.3' },
  { testNo: 58, questionNo: 3, code: '21.5.2' },
  { testNo: 58, questionNo: 4, code: '21.3' },
  { testNo: 58, questionNo: 5, code: '21.5.2' },
  { testNo: 58, questionNo: 6, code: '21.5.1' },
  { testNo: 58, questionNo: 7, code: '21.5.1' },
  { testNo: 59, questionNo: 1, code: '21.4.4' },
  { testNo: 59, questionNo: 2, code: '21.5.2' },
  { testNo: 59, questionNo: 3, code: '21.5.4' },
  { testNo: 59, questionNo: 4, code: '21.5.3' },
  { testNo: 59, questionNo: 5, code: '21.5.2' },
  { testNo: 59, questionNo: 6, code: '21.5.1' },
  { testNo: 59, questionNo: 7, code: '21.5.2' },
  { testNo: 60, questionNo: 1, code: '21.5.2' },
  { testNo: 60, questionNo: 2, code: '21.5.4' },
  { testNo: 60, questionNo: 3, code: '21.4.1' },
  { testNo: 60, questionNo: 4, code: '21.5.2' },
  { testNo: 60, questionNo: 5, code: '21.5.6' },
  { testNo: 60, questionNo: 6, code: '21.5.2' },
  { testNo: 60, questionNo: 7, code: '21.4.2' },
  { testNo: 60, questionNo: 8, code: '21.5.2' },
  { testNo: 61, questionNo: 1, code: '21.5.1' },
  { testNo: 61, questionNo: 2, code: '21.4.1' },
  { testNo: 61, questionNo: 3, code: '21.4.5' },
  { testNo: 61, questionNo: 4, code: '21.5.2' },
  { testNo: 61, questionNo: 5, code: '21.5.2' },
  { testNo: 61, questionNo: 6, code: '21.4.2' },
  { testNo: 61, questionNo: 7, code: '21.5.4' },
  { testNo: 61, questionNo: 8, code: '21.5.6' },
  { testNo: 62, questionNo: 1, code: '21.3' },
  { testNo: 62, questionNo: 2, code: '21.5.1' },
  { testNo: 62, questionNo: 3, code: '21.5.2' },
  { testNo: 62, questionNo: 4, code: '21.4.4' },
  { testNo: 62, questionNo: 5, code: '21.5.2' },
  { testNo: 62, questionNo: 6, code: '21.5.6' },
  { testNo: 62, questionNo: 7, code: '21.5.2' },
  { testNo: 62, questionNo: 8, code: '21.5.6' },
  { testNo: 63, questionNo: 1, code: '21.4.1' },
  { testNo: 63, questionNo: 2, code: '21.5.6' },
  { testNo: 63, questionNo: 3, code: '21.4.2' },
  { testNo: 63, questionNo: 4, code: '21.5.2' },
  { testNo: 63, questionNo: 5, code: '21.4.3' },
  { testNo: 63, questionNo: 6, code: '21.5.2' },
  { testNo: 63, questionNo: 7, code: '21.5.2' },
  { testNo: 63, questionNo: 8, code: '21.3' },
  { testNo: 64, questionNo: 1, code: '21.4.6' },
  { testNo: 64, questionNo: 2, code: '21.5.2' },
  { testNo: 64, questionNo: 3, code: '21.5.6' },
  { testNo: 64, questionNo: 4, code: '21.5.1' },
  { testNo: 64, questionNo: 5, code: '21.5.6' },
  { testNo: 64, questionNo: 6, code: '21.5.3' },
  { testNo: 65, questionNo: 1, code: '21.4.3' },
  { testNo: 65, questionNo: 2, code: '21.5.2' },
  { testNo: 65, questionNo: 3, code: '21.4.2' },
  { testNo: 65, questionNo: 4, code: '21.5.2' },
  { testNo: 65, questionNo: 5, code: '21.5.6' },
  { testNo: 65, questionNo: 6, code: '21.3' },
  { testNo: 65, questionNo: 7, code: '21.5.6' },
  { testNo: 65, questionNo: 8, code: '21.5.2' },
  { testNo: 66, questionNo: 1, code: '21.4.3' },
  { testNo: 66, questionNo: 2, code: '21.5.1' },
  { testNo: 66, questionNo: 3, code: '21.5.2' },
  { testNo: 66, questionNo: 4, code: '21.5.6' },
  { testNo: 66, questionNo: 5, code: '21.5.2' },
  { testNo: 66, questionNo: 6, code: '21.4.1' },
  { testNo: 66, questionNo: 7, code: '21.5.2' },
  { testNo: 66, questionNo: 8, code: '21.4.2' },
  { testNo: 67, questionNo: 1, code: '21.4.2' },
  { testNo: 67, questionNo: 2, code: '21.5.1' },
  { testNo: 67, questionNo: 3, code: '21.5.6' },
  { testNo: 67, questionNo: 4, code: '21.5.2' },
  { testNo: 67, questionNo: 5, code: '21.5.3' },
  { testNo: 67, questionNo: 6, code: '21.4.4' },
  { testNo: 67, questionNo: 7, code: '21.5.2' },
  { testNo: 68, questionNo: 1, code: '21.5.2' },
  { testNo: 68, questionNo: 2, code: '21.4.2' },
  { testNo: 68, questionNo: 3, code: '21.5.2' },
  { testNo: 68, questionNo: 4, code: '21.4.4' },
  { testNo: 68, questionNo: 5, code: '21.5.2' },
  { testNo: 68, questionNo: 6, code: '21.4.1' },
  { testNo: 68, questionNo: 7, code: '21.5.2' },
  { testNo: 69, questionNo: 1, code: '21.4.2' },
  { testNo: 69, questionNo: 2, code: '21.4.6' },
  { testNo: 69, questionNo: 3, code: '21.4.1' },
  { testNo: 69, questionNo: 4, code: '21.5.2' },
  { testNo: 69, questionNo: 5, code: '21.5.2' },
  { testNo: 69, questionNo: 6, code: '21.5.4' },
  { testNo: 69, questionNo: 7, code: '21.5.3' },
  { testNo: 69, questionNo: 8, code: '21.5.4' },
  { testNo: 70, questionNo: 1, code: '21.5.4' },
  { testNo: 70, questionNo: 2, code: '21.4.3' },
  { testNo: 70, questionNo: 3, code: '21.5.6' },
  { testNo: 70, questionNo: 4, code: '21.4.5' },
  { testNo: 70, questionNo: 5, code: '21.5.6' },
  { testNo: 70, questionNo: 6, code: '21.5.1' },
  { testNo: 70, questionNo: 7, code: '21.5.2' },
  { testNo: 71, questionNo: 1, code: '21.5.2' },
  { testNo: 71, questionNo: 2, code: '21.4.2' },
  { testNo: 71, questionNo: 3, code: '21.4.6' },
  { testNo: 71, questionNo: 4, code: '21.5.4' },
  { testNo: 71, questionNo: 5, code: '21.4.3' },
  { testNo: 71, questionNo: 6, code: '21.5.1' },
  { testNo: 71, questionNo: 7, code: '21.5.6' },
  { testNo: 71, questionNo: 8, code: '21.5.4' },
  { testNo: 72, questionNo: 1, code: '21.5.2' },
  { testNo: 72, questionNo: 2, code: '21.3' },
  { testNo: 72, questionNo: 3, code: '21.5.1' },
  { testNo: 72, questionNo: 4, code: '21.4.2' },
  { testNo: 72, questionNo: 5, code: '21.5.1' },
  { testNo: 72, questionNo: 6, code: '21.5.2' },
  { testNo: 72, questionNo: 7, code: '21.5.1' },
  { testNo: 73, questionNo: 1, code: '21.5.2' },
  { testNo: 73, questionNo: 2, code: '21.4.1' },
  { testNo: 73, questionNo: 3, code: '21.5.1' },
  { testNo: 73, questionNo: 4, code: '21.5.1' },
  { testNo: 73, questionNo: 5, code: '21.5.2' },
  { testNo: 73, questionNo: 6, code: '21.3' },
  { testNo: 73, questionNo: 7, code: '21.5.3' },
  { testNo: 74, questionNo: 1, code: '21.4.3' },
  { testNo: 74, questionNo: 2, code: '21.5.4' },
  { testNo: 74, questionNo: 3, code: '21.5.1' },
  { testNo: 74, questionNo: 4, code: '21.4.4' },
  { testNo: 74, questionNo: 5, code: '21.5.2' },
  { testNo: 74, questionNo: 6, code: '21.5.1' },
  { testNo: 74, questionNo: 7, code: '21.5.2' },
  { testNo: 75, questionNo: 1, code: '21.4.5' },
  { testNo: 75, questionNo: 2, code: '21.5.2' },
  { testNo: 75, questionNo: 3, code: '21.5.1' },
  { testNo: 75, questionNo: 4, code: '21.5.1' },
  { testNo: 75, questionNo: 5, code: '21.5.6' },
  { testNo: 75, questionNo: 6, code: '21.4.1' },
  { testNo: 75, questionNo: 7, code: '21.5.2' },
  { testNo: 75, questionNo: 8, code: '21.5.4' },
  { testNo: 76, questionNo: 1, code: '21.5.1' },
  { testNo: 76, questionNo: 2, code: '21.5.2' },
  { testNo: 76, questionNo: 3, code: '21.4.3' },
  { testNo: 76, questionNo: 4, code: '21.5.2' },
  { testNo: 76, questionNo: 5, code: '21.5.1' },
  { testNo: 76, questionNo: 6, code: '21.4.2' },
  { testNo: 76, questionNo: 7, code: '21.5.2' },
  { testNo: 76, questionNo: 8, code: '21.5.2' },
  { testNo: 77, questionNo: 1, code: '21.4.5' },
  { testNo: 77, questionNo: 2, code: '21.5.6' },
  { testNo: 77, questionNo: 3, code: '21.5.2' },
  { testNo: 77, questionNo: 4, code: '21.4.1' },
  { testNo: 77, questionNo: 5, code: '21.5.1' },
  { testNo: 77, questionNo: 6, code: '21.5.2' },
  { testNo: 77, questionNo: 7, code: '21.5.4' },
  { testNo: 77, questionNo: 8, code: '21.5.1' },
  { testNo: 78, questionNo: 1, code: '21.5.6' },
  { testNo: 78, questionNo: 2, code: '21.5.2' },
  { testNo: 78, questionNo: 3, code: '21.5.6' },
  { testNo: 78, questionNo: 4, code: '21.5.1' },
  { testNo: 78, questionNo: 5, code: '21.3' },
  { testNo: 78, questionNo: 6, code: '21.5.1' },
  { testNo: 78, questionNo: 7, code: '21.5.2' },
  { testNo: 78, questionNo: 8, code: '21.5.1' },
  { testNo: 79, questionNo: 1, code: '21.4.4' },
  { testNo: 79, questionNo: 2, code: '21.5.6' },
  { testNo: 79, questionNo: 3, code: '21.5.2' },
  { testNo: 79, questionNo: 4, code: '21.4.3' },
  { testNo: 79, questionNo: 5, code: '21.5.1' },
  { testNo: 79, questionNo: 6, code: '21.4.5' },
  { testNo: 79, questionNo: 7, code: '21.5.4' },
  { testNo: 79, questionNo: 8, code: '21.5.1' },
  { testNo: 80, questionNo: 1, code: '21.5.6' },
  { testNo: 80, questionNo: 2, code: '21.4.2' },
  { testNo: 80, questionNo: 3, code: '21.5.1' },
  { testNo: 80, questionNo: 4, code: '21.5.2' },
  { testNo: 80, questionNo: 5, code: '21.5.2' },
  { testNo: 80, questionNo: 6, code: '21.4.1' },
  { testNo: 80, questionNo: 7, code: '21.5.1' },
  { testNo: 80, questionNo: 8, code: '21.5.3' },
  { testNo: 81, questionNo: 1, code: '21.5.6' },
  { testNo: 81, questionNo: 2, code: '21.5.1' },
  { testNo: 81, questionNo: 3, code: '21.5.2' },
  { testNo: 81, questionNo: 4, code: '21.4.6' },
  { testNo: 81, questionNo: 5, code: '21.3' },
  { testNo: 81, questionNo: 6, code: '21.5.2' },
  { testNo: 81, questionNo: 7, code: '21.5.4' },
  { testNo: 81, questionNo: 8, code: '21.5.2' },
  { testNo: 82, questionNo: 1, code: '21.4.2' },
  { testNo: 82, questionNo: 2, code: '21.5.4' },
  { testNo: 82, questionNo: 3, code: '21.5.2' },
  { testNo: 82, questionNo: 4, code: '21.5.1' },
  { testNo: 82, questionNo: 5, code: '21.5.6' },
  { testNo: 82, questionNo: 6, code: '21.4.1' },
  { testNo: 82, questionNo: 7, code: '21.5.2' },
  { testNo: 82, questionNo: 8, code: '21.4.3' },
  { testNo: 83, questionNo: 1, code: '21.4.2' },
  { testNo: 83, questionNo: 2, code: '21.5.1' },
  { testNo: 83, questionNo: 3, code: '21.5.2' },
  { testNo: 83, questionNo: 4, code: '21.5.6' },
  { testNo: 83, questionNo: 5, code: '21.4.1' },
  { testNo: 83, questionNo: 6, code: '21.5.3' },
  { testNo: 83, questionNo: 7, code: '21.5.2' },
  { testNo: 83, questionNo: 8, code: '21.5.1' },
  { testNo: 84, questionNo: 1, code: '21.4.2' },
  { testNo: 84, questionNo: 2, code: '21.5.2' },
  { testNo: 84, questionNo: 3, code: '21.5.6' },
  { testNo: 84, questionNo: 4, code: '21.5.1' },
  { testNo: 84, questionNo: 5, code: '21.4.5' },
  { testNo: 84, questionNo: 6, code: '21.5.2' },
  { testNo: 84, questionNo: 7, code: '21.5.2' },
  { testNo: 84, questionNo: 8, code: '21.5.4' },
  { testNo: 85, questionNo: 1, code: '21.5.4' },
  { testNo: 85, questionNo: 2, code: '21.4.4' },
  { testNo: 85, questionNo: 3, code: '21.5.2' },
  { testNo: 85, questionNo: 4, code: '21.5.1' },
  { testNo: 85, questionNo: 5, code: '21.5.2' },
  { testNo: 85, questionNo: 6, code: '21.5.1' },
  { testNo: 85, questionNo: 7, code: '21.5.1' },
  { testNo: 85, questionNo: 8, code: '21.5.2' },
  { testNo: 86, questionNo: 1, code: '21.4.1' },
  { testNo: 86, questionNo: 2, code: '21.5.2' },
  { testNo: 86, questionNo: 3, code: '21.4.3' },
  { testNo: 86, questionNo: 4, code: '21.5.6' },
  { testNo: 86, questionNo: 5, code: '21.5.4' },
  { testNo: 86, questionNo: 6, code: '21.5.1' },
  { testNo: 86, questionNo: 7, code: '21.5.2' },
  { testNo: 86, questionNo: 8, code: '21.5.2' },
  { testNo: 87, questionNo: 1, code: '21.4.5' },
  { testNo: 87, questionNo: 2, code: '21.5.2' },
  { testNo: 87, questionNo: 3, code: '21.4.2' },
  { testNo: 87, questionNo: 4, code: '21.5.6' },
  { testNo: 87, questionNo: 5, code: '21.4.3' },
  { testNo: 87, questionNo: 6, code: '21.5.2' },
  { testNo: 87, questionNo: 7, code: '21.5.3' },
  { testNo: 88, questionNo: 1, code: '21.4.4' },
  { testNo: 88, questionNo: 2, code: '21.5.2' },
  { testNo: 88, questionNo: 3, code: '21.5.6' },
  { testNo: 88, questionNo: 4, code: '21.5.6' },
  { testNo: 88, questionNo: 5, code: '21.5.1' },
  { testNo: 88, questionNo: 6, code: '21.4.2' },
  { testNo: 88, questionNo: 7, code: '21.5.2' },
  { testNo: 88, questionNo: 8, code: '21.5.1' },
  { testNo: 89, questionNo: 1, code: '21.3' },
  { testNo: 89, questionNo: 2, code: '21.5.6' },
  { testNo: 89, questionNo: 3, code: '21.4.1' },
  { testNo: 89, questionNo: 4, code: '21.5.2' },
  { testNo: 89, questionNo: 5, code: '21.5.1' },
  { testNo: 89, questionNo: 6, code: '21.5.2' },
  { testNo: 89, questionNo: 7, code: '21.5.2' },
  { testNo: 89, questionNo: 8, code: '21.5.6' },
  { testNo: 90, questionNo: 1, code: '21.4.6' },
  { testNo: 90, questionNo: 2, code: '21.5.1' },
  { testNo: 90, questionNo: 3, code: '21.5.3' },
  { testNo: 90, questionNo: 4, code: '21.5.2' },
  { testNo: 90, questionNo: 5, code: '21.4.2' },
  { testNo: 90, questionNo: 6, code: '21.5.1' },
  { testNo: 90, questionNo: 7, code: '21.5.2' },
  { testNo: 91, questionNo: 1, code: '21.5.1' },
  { testNo: 91, questionNo: 2, code: '21.5.2' },
  { testNo: 91, questionNo: 3, code: '21.5.2' },
  { testNo: 91, questionNo: 4, code: '21.4.1' },
  { testNo: 91, questionNo: 5, code: '21.5.6' },
  { testNo: 91, questionNo: 6, code: '21.4.3' },
  { testNo: 91, questionNo: 7, code: '21.3' },
  { testNo: 91, questionNo: 8, code: '21.4.6' },
  { testNo: 92, questionNo: 1, code: '21.5.2' },
  { testNo: 92, questionNo: 2, code: '21.4.4' },
  { testNo: 92, questionNo: 3, code: '21.5.1' },
  { testNo: 92, questionNo: 4, code: '21.5.2' },
  { testNo: 92, questionNo: 5, code: '21.5.1' },
  { testNo: 92, questionNo: 6, code: '21.5.6' },
  { testNo: 92, questionNo: 7, code: '21.4.2' },
  { testNo: 92, questionNo: 8, code: '21.5.1' },
  { testNo: 93, questionNo: 1, code: '21.5.4' },
  { testNo: 93, questionNo: 2, code: '21.4.5' },
  { testNo: 93, questionNo: 3, code: '21.5.2' },
  { testNo: 93, questionNo: 4, code: '21.5.2' },
  { testNo: 93, questionNo: 5, code: '21.5.6' },
  { testNo: 93, questionNo: 6, code: '21.5.2' },
  { testNo: 93, questionNo: 7, code: '21.5.1' },
  { testNo: 93, questionNo: 8, code: '21.5.4' },
  { testNo: 94, questionNo: 1, code: '21.5.1' },
  { testNo: 94, questionNo: 2, code: '21.5.2' },
  { testNo: 94, questionNo: 3, code: '21.5.3' },
  { testNo: 94, questionNo: 4, code: '21.4.1' },
  { testNo: 94, questionNo: 5, code: '21.4.1' },
  { testNo: 94, questionNo: 6, code: '21.4.2' },
  { testNo: 94, questionNo: 7, code: '21.5.4' },
  { testNo: 95, questionNo: 1, code: '21.5.6' },
  { testNo: 95, questionNo: 2, code: '21.4.3' },
  { testNo: 95, questionNo: 3, code: '21.4.2' },
  { testNo: 95, questionNo: 4, code: '21.5.6' },
  { testNo: 95, questionNo: 5, code: '21.5.4' },
  { testNo: 95, questionNo: 6, code: '21.5.1' },
  { testNo: 95, questionNo: 7, code: '21.5.4' },
  { testNo: 95, questionNo: 8, code: '21.5.2' },
  { testNo: 96, questionNo: 1, code: '21.4.1' },
  { testNo: 96, questionNo: 2, code: '21.5.2' },
  { testNo: 96, questionNo: 3, code: '21.5.4' },
  { testNo: 96, questionNo: 4, code: '21.5.6' },
  { testNo: 96, questionNo: 5, code: '21.5.2' },
  { testNo: 96, questionNo: 6, code: '21.5.1' },
  { testNo: 96, questionNo: 7, code: '21.5.2' },
  { testNo: 96, questionNo: 8, code: '21.5.1' },
  { testNo: 97, questionNo: 1, code: '21.4.3' },
  { testNo: 97, questionNo: 2, code: '21.5.2' },
  { testNo: 97, questionNo: 3, code: '21.4.4' },
  { testNo: 97, questionNo: 4, code: '21.5.4' },
  { testNo: 97, questionNo: 5, code: '21.5.6' },
  { testNo: 97, questionNo: 6, code: '21.5.1' },
  { testNo: 97, questionNo: 7, code: '21.5.6' },
  { testNo: 97, questionNo: 8, code: '21.5.1' },
  { testNo: 98, questionNo: 1, code: '21.5.3' },
  { testNo: 98, questionNo: 2, code: '21.5.2' },
  { testNo: 98, questionNo: 3, code: '21.5.4' },
  { testNo: 98, questionNo: 4, code: '21.4.1' },
  { testNo: 98, questionNo: 5, code: '21.4.4' },
  { testNo: 98, questionNo: 6, code: '21.5.1' },
  { testNo: 99, questionNo: 1, code: '21.4.5' },
  { testNo: 99, questionNo: 2, code: '21.5.1' },
  { testNo: 99, questionNo: 3, code: '21.4.3' },
  { testNo: 99, questionNo: 4, code: '21.5.2' },
  { testNo: 99, questionNo: 5, code: '21.5.2' },
  { testNo: 99, questionNo: 6, code: '21.5.2' },
  { testNo: 99, questionNo: 7, code: '21.5.2' },
  { testNo: 99, questionNo: 8, code: '21.5.1' },
  { testNo: 100, questionNo: 1, code: '21.5.2' },
  { testNo: 100, questionNo: 2, code: '21.5.1' },
  { testNo: 100, questionNo: 3, code: '21.5.4' },
  { testNo: 100, questionNo: 4, code: '21.4.6' },
  { testNo: 100, questionNo: 5, code: '21.5.1' },
  { testNo: 100, questionNo: 6, code: '21.5.6' },
  { testNo: 100, questionNo: 7, code: '21.5.2' },
  { testNo: 101, questionNo: 1, code: '21.4.1' },
  { testNo: 101, questionNo: 2, code: '21.5.1' },
  { testNo: 101, questionNo: 3, code: '21.5.2' },
  { testNo: 101, questionNo: 4, code: '21.4.2' },
  { testNo: 101, questionNo: 5, code: '21.5.6' },
  { testNo: 101, questionNo: 6, code: '21.5.1' },
  { testNo: 101, questionNo: 7, code: '21.5.2' },
  { testNo: 102, questionNo: 1, code: '21.4.3' },
  { testNo: 102, questionNo: 2, code: '21.5.1' },
  { testNo: 102, questionNo: 3, code: '21.5.4' },
  { testNo: 102, questionNo: 4, code: '21.5.2' },
  { testNo: 102, questionNo: 5, code: '21.3' },
  { testNo: 102, questionNo: 6, code: '21.5.2' },
  { testNo: 102, questionNo: 7, code: '21.5.6' },
  { testNo: 102, questionNo: 8, code: '21.5.4' },
  { testNo: 103, questionNo: 1, code: '21.5.1' },
  { testNo: 103, questionNo: 2, code: '21.5.1' },
  { testNo: 103, questionNo: 3, code: '21.5.1' },
  { testNo: 103, questionNo: 4, code: '21.4.5' },
  { testNo: 103, questionNo: 5, code: '21.5.2' },
  { testNo: 103, questionNo: 6, code: '21.5.4' },
  { testNo: 103, questionNo: 7, code: '21.5.2' },
  { testNo: 103, questionNo: 8, code: '21.4.5' },
  { testNo: 104, questionNo: 1, code: '21.4.3' },
  { testNo: 104, questionNo: 2, code: '21.5.2' },
  { testNo: 104, questionNo: 3, code: '21.5.2' },
  { testNo: 104, questionNo: 4, code: '21.5.2' },
  { testNo: 104, questionNo: 5, code: '21.4.2' },
  { testNo: 104, questionNo: 6, code: '21.5.2' },
  { testNo: 104, questionNo: 7, code: '21.5.2' },
  { testNo: 104, questionNo: 8, code: '21.5.4' },
  { testNo: 105, questionNo: 1, code: '21.4.4' },
  { testNo: 105, questionNo: 2, code: '21.5.1' },
  { testNo: 105, questionNo: 3, code: '21.5.2' },
  { testNo: 105, questionNo: 4, code: '21.5.1' },
  { testNo: 105, questionNo: 5, code: '21.5.2' },
  { testNo: 105, questionNo: 6, code: '21.5.2' },
  { testNo: 105, questionNo: 7, code: '21.5.6' },
  { testNo: 105, questionNo: 8, code: '21.5.2' },
  { testNo: 106, questionNo: 1, code: '21.4.1' },
  { testNo: 106, questionNo: 2, code: '21.5.1' },
  { testNo: 106, questionNo: 3, code: '21.4.3' },
  { testNo: 106, questionNo: 4, code: '21.5.2' },
  { testNo: 106, questionNo: 5, code: '21.5.1' },
  { testNo: 106, questionNo: 6, code: '21.5.2' },
  { testNo: 106, questionNo: 7, code: '21.5.1' },
  { testNo: 107, questionNo: 1, code: '21.4.4' },
  { testNo: 107, questionNo: 2, code: '21.5.6' },
  { testNo: 107, questionNo: 3, code: '21.5.2' },
  { testNo: 107, questionNo: 4, code: '21.5.1' },
  { testNo: 107, questionNo: 5, code: '21.5.1' },
  { testNo: 107, questionNo: 6, code: '21.5.2' },
  { testNo: 107, questionNo: 7, code: '21.5.1' },
  { testNo: 107, questionNo: 8, code: '21.5.6' },
  { testNo: 108, questionNo: 1, code: '21.4.2' },
  { testNo: 108, questionNo: 2, code: '21.5.1' },
  { testNo: 108, questionNo: 3, code: '21.5.2' },
  { testNo: 108, questionNo: 4, code: '21.3' },
  { testNo: 108, questionNo: 5, code: '21.5.4' },
  { testNo: 108, questionNo: 6, code: '21.5.1' },
  { testNo: 109, questionNo: 1, code: '21.4.1' },
  { testNo: 109, questionNo: 2, code: '21.5.2' },
  { testNo: 109, questionNo: 3, code: '21.5.3' },
  { testNo: 109, questionNo: 4, code: '21.5.2' },
  { testNo: 109, questionNo: 5, code: '21.5.2' },
  { testNo: 109, questionNo: 6, code: '21.5.4' },
  { testNo: 109, questionNo: 7, code: '21.5.4' },
  { testNo: 109, questionNo: 8, code: '21.5.2' },
  { testNo: 110, questionNo: 1, code: '21.4.2' },
  { testNo: 110, questionNo: 2, code: '21.5.4' },
  { testNo: 110, questionNo: 3, code: '21.5.2' },
  { testNo: 110, questionNo: 4, code: '21.5.1' },
  { testNo: 110, questionNo: 5, code: '21.4.1' },
  { testNo: 110, questionNo: 6, code: '21.5.2' },
  { testNo: 110, questionNo: 7, code: '21.5.2' },
  { testNo: 111, questionNo: 1, code: '21.4.1' },
  { testNo: 111, questionNo: 2, code: '21.5.1' },
  { testNo: 111, questionNo: 3, code: '21.5.2' },
  { testNo: 111, questionNo: 4, code: '21.4.2' },
  { testNo: 111, questionNo: 5, code: '21.5.2' },
  { testNo: 111, questionNo: 6, code: '21.5.2' },
  { testNo: 111, questionNo: 7, code: '21.5.3' },
  { testNo: 112, questionNo: 1, code: '21.4.1' },
  { testNo: 112, questionNo: 2, code: '21.5.2' },
  { testNo: 112, questionNo: 3, code: '21.5.6' },
  { testNo: 112, questionNo: 4, code: '21.5.2' },
  { testNo: 112, questionNo: 5, code: '21.5.2' },
  { testNo: 112, questionNo: 6, code: '21.5.6' },
  { testNo: 112, questionNo: 7, code: '21.5.1' },
  { testNo: 112, questionNo: 8, code: '21.3' },
  { testNo: 113, questionNo: 1, code: '21.4.3' },
  { testNo: 113, questionNo: 2, code: '21.5.2' },
  { testNo: 113, questionNo: 3, code: '21.5.1' },
  { testNo: 113, questionNo: 4, code: '21.5.2' },
  { testNo: 113, questionNo: 5, code: '21.5.2' },
  { testNo: 113, questionNo: 6, code: '21.5.6' },
  { testNo: 113, questionNo: 7, code: '21.5.6' },
  { testNo: 113, questionNo: 8, code: '21.5.1' },
  { testNo: 114, questionNo: 1, code: '21.4.4' },
  { testNo: 114, questionNo: 2, code: '21.5.2' },
  { testNo: 114, questionNo: 3, code: '21.5.2' },
  { testNo: 114, questionNo: 4, code: '21.3' },
  { testNo: 114, questionNo: 5, code: '21.5.1' },
  { testNo: 114, questionNo: 6, code: '21.5.2' },
  { testNo: 114, questionNo: 7, code: '21.5.1' },
  { testNo: 114, questionNo: 8, code: '21.5.2' },
  { testNo: 115, questionNo: 1, code: '21.4.3' },
  { testNo: 115, questionNo: 2, code: '21.5.1' },
  { testNo: 115, questionNo: 3, code: '21.5.2' },
  { testNo: 115, questionNo: 4, code: '21.5.2' },
  { testNo: 115, questionNo: 5, code: '21.4.2' },
  { testNo: 115, questionNo: 6, code: '21.4.5' },
  { testNo: 115, questionNo: 7, code: '21.5.2' },
  { testNo: 116, questionNo: 1, code: '21.4.2' },
  { testNo: 116, questionNo: 2, code: '21.5.2' },
  { testNo: 116, questionNo: 3, code: '21.4.4' },
  { testNo: 116, questionNo: 4, code: '21.5.2' },
  { testNo: 116, questionNo: 5, code: '21.5.4' },
  { testNo: 116, questionNo: 6, code: '21.5.6' },
  { testNo: 116, questionNo: 7, code: '21.5.3' },
  { testNo: 116, questionNo: 8, code: '21.5.2' },
  { testNo: 117, questionNo: 1, code: '21.4.1' },
  { testNo: 117, questionNo: 2, code: '21.5.6' },
  { testNo: 117, questionNo: 3, code: '21.5.2' },
  { testNo: 117, questionNo: 4, code: '21.4.3' },
  { testNo: 117, questionNo: 5, code: '21.5.2' },
  { testNo: 117, questionNo: 6, code: '21.4.6' },
  { testNo: 117, questionNo: 7, code: '21.5.1' },
  { testNo: 117, questionNo: 8, code: '21.5.1' },
  { testNo: 118, questionNo: 1, code: '21.3' },
  { testNo: 118, questionNo: 2, code: '21.5.6' },
  { testNo: 118, questionNo: 3, code: '21.4.2' },
  { testNo: 118, questionNo: 4, code: '21.4.3' },
  { testNo: 118, questionNo: 5, code: '21.5.2' },
  { testNo: 118, questionNo: 6, code: '21.5.2' },
  { testNo: 119, questionNo: 1, code: '21.4.1' },
  { testNo: 119, questionNo: 2, code: '21.5.2' },
  { testNo: 119, questionNo: 3, code: '21.5.1' },
  { testNo: 119, questionNo: 4, code: '21.5.2' },
  { testNo: 119, questionNo: 5, code: '21.4.2' },
  { testNo: 119, questionNo: 6, code: '21.5.2' },
  { testNo: 119, questionNo: 7, code: '21.5.2' },
  { testNo: 119, questionNo: 8, code: '21.5.4' },
  { testNo: 120, questionNo: 1, code: '21.4.5' },
  { testNo: 120, questionNo: 2, code: '21.5.4' },
  { testNo: 120, questionNo: 3, code: '21.5.2' },
  { testNo: 120, questionNo: 4, code: '21.5.2' },
  { testNo: 120, questionNo: 5, code: '21.5.2' },
  { testNo: 120, questionNo: 6, code: '21.5.1' },
  { testNo: 120, questionNo: 7, code: '21.5.3' },
  { testNo: 121, questionNo: 1, code: '21.5.6' },
  { testNo: 121, questionNo: 2, code: '21.5.2' },
  { testNo: 121, questionNo: 3, code: '21.4.4' },
  { testNo: 121, questionNo: 4, code: '21.5.4' },
  { testNo: 121, questionNo: 5, code: '21.4.2' },
  { testNo: 121, questionNo: 6, code: '21.5.6' },
  { testNo: 121, questionNo: 7, code: '21.5.2' },
  { testNo: 122, questionNo: 1, code: '21.4.5' },
  { testNo: 122, questionNo: 2, code: '21.5.4' },
  { testNo: 122, questionNo: 3, code: '21.5.2' },
  { testNo: 122, questionNo: 4, code: '21.4.2' },
  { testNo: 122, questionNo: 5, code: '21.5.2' },
  { testNo: 122, questionNo: 6, code: '21.5.4' },
  { testNo: 123, questionNo: 1, code: '21.4.1' },
  { testNo: 123, questionNo: 2, code: '21.5.2' },
  { testNo: 123, questionNo: 3, code: '21.5.2' },
  { testNo: 123, questionNo: 4, code: '21.4.3' },
  { testNo: 123, questionNo: 5, code: '21.5.4' },
  { testNo: 123, questionNo: 6, code: '21.5.4' },
  { testNo: 123, questionNo: 7, code: '21.5.4' },
  { testNo: 123, questionNo: 8, code: '21.3' },
  { testNo: 124, questionNo: 1, code: '21.5.6' },
  { testNo: 124, questionNo: 2, code: '21.4.3' },
  { testNo: 124, questionNo: 3, code: '21.5.2' },
  { testNo: 124, questionNo: 4, code: '21.5.6' },
  { testNo: 124, questionNo: 5, code: '21.4.2' },
  { testNo: 124, questionNo: 6, code: '21.4.5' },
  { testNo: 124, questionNo: 7, code: '21.5.6' },
  { testNo: 124, questionNo: 8, code: '21.5.6' },
  { testNo: 125, questionNo: 1, code: '21.5.4' },
  { testNo: 125, questionNo: 2, code: '21.5.4' },
  { testNo: 125, questionNo: 3, code: '21.4.1' },
  { testNo: 125, questionNo: 4, code: '21.5.2' },
  { testNo: 125, questionNo: 5, code: '21.5.3' },
  { testNo: 125, questionNo: 6, code: '21.5.1' },
  { testNo: 125, questionNo: 7, code: '21.5.4' },
  { testNo: 125, questionNo: 8, code: '21.3' },
  { testNo: 126, questionNo: 1, code: '21.4.3' },
  { testNo: 126, questionNo: 2, code: '21.5.2' },
  { testNo: 126, questionNo: 3, code: '21.5.6' },
  { testNo: 126, questionNo: 4, code: '21.5.2' },
  { testNo: 126, questionNo: 5, code: '21.5.2' },
  { testNo: 126, questionNo: 6, code: '21.5.2' },
  { testNo: 126, questionNo: 7, code: '21.4.5' },
  { testNo: 126, questionNo: 8, code: '21.5.1' },
  { testNo: 127, questionNo: 1, code: '21.5.1' },
  { testNo: 127, questionNo: 2, code: '21.4.1' },
  { testNo: 127, questionNo: 3, code: '21.5.2' },
  { testNo: 127, questionNo: 4, code: '21.5.6' },
  { testNo: 127, questionNo: 5, code: '21.5.1' },
  { testNo: 127, questionNo: 6, code: '21.5.1' },
  { testNo: 127, questionNo: 7, code: '21.5.6' },
  { testNo: 128, questionNo: 1, code: '21.5.3' },
  { testNo: 128, questionNo: 2, code: '21.4.2' },
  { testNo: 128, questionNo: 3, code: '21.4.5' },
  { testNo: 128, questionNo: 4, code: '21.5.2' },
  { testNo: 128, questionNo: 5, code: '21.5.2' },
  { testNo: 128, questionNo: 6, code: '21.4.4' },
  { testNo: 128, questionNo: 7, code: '21.5.4' },
  { testNo: 128, questionNo: 8, code: '21.5.6' },
  { testNo: 129, questionNo: 1, code: '21.3' },
  { testNo: 129, questionNo: 2, code: '21.5.2' },
  { testNo: 129, questionNo: 3, code: '21.4.3' },
  { testNo: 129, questionNo: 4, code: '21.5.6' },
  { testNo: 129, questionNo: 5, code: '21.5.2' },
  { testNo: 129, questionNo: 6, code: '21.5.6' },
  { testNo: 129, questionNo: 7, code: '21.5.2' },
  { testNo: 129, questionNo: 8, code: '21.5.2' },
  { testNo: 130, questionNo: 1, code: '21.5.2' },
  { testNo: 130, questionNo: 2, code: '21.5.6' },
  { testNo: 130, questionNo: 3, code: '21.5.4' },
  { testNo: 130, questionNo: 4, code: '21.4.1' },
  { testNo: 130, questionNo: 5, code: '21.5.4' },
  { testNo: 130, questionNo: 6, code: '21.4.4' },
  { testNo: 130, questionNo: 7, code: '21.5.2' },
  { testNo: 131, questionNo: 1, code: '21.4.2' },
  { testNo: 131, questionNo: 2, code: '21.3' },
  { testNo: 131, questionNo: 3, code: '21.5.2' },
  { testNo: 131, questionNo: 4, code: '21.5.2' },
  { testNo: 131, questionNo: 5, code: '21.5.1' },
  { testNo: 131, questionNo: 6, code: '21.4.4' },
  { testNo: 131, questionNo: 7, code: '21.5.6' },
  { testNo: 131, questionNo: 8, code: '21.5.2' },
  { testNo: 132, questionNo: 1, code: '21.4.1' },
  { testNo: 132, questionNo: 2, code: '21.5.2' },
  { testNo: 132, questionNo: 3, code: '21.5.4' },
  { testNo: 132, questionNo: 4, code: '21.5.4' },
  { testNo: 132, questionNo: 5, code: '21.5.2' },
  { testNo: 132, questionNo: 6, code: '21.5.3' },
  { testNo: 132, questionNo: 7, code: '21.5.4' },
  { testNo: 133, questionNo: 1, code: '21.4.2' },
  { testNo: 133, questionNo: 2, code: '21.5.2' },
  { testNo: 133, questionNo: 3, code: '21.5.2' },
  { testNo: 133, questionNo: 4, code: '21.4.3' },
  { testNo: 133, questionNo: 5, code: '21.5.4' },
  { testNo: 133, questionNo: 6, code: '21.5.6' },
  { testNo: 133, questionNo: 7, code: '21.5.2' },
  { testNo: 134, questionNo: 1, code: '21.5.6' },
  { testNo: 134, questionNo: 2, code: '21.4.1' },
  { testNo: 134, questionNo: 3, code: '21.5.2' },
  { testNo: 134, questionNo: 4, code: '21.4.4' },
  { testNo: 134, questionNo: 5, code: '21.5.6' },
  { testNo: 134, questionNo: 6, code: '21.5.1' },
  { testNo: 134, questionNo: 7, code: '21.5.6' },
  { testNo: 134, questionNo: 8, code: '21.5.2' },
  { testNo: 135, questionNo: 1, code: '21.5.2' },
  { testNo: 135, questionNo: 2, code: '21.5.4' },
  { testNo: 135, questionNo: 3, code: '21.4.3' },
  { testNo: 135, questionNo: 4, code: '21.5.1' },
  { testNo: 135, questionNo: 5, code: '21.5.2' },
  { testNo: 135, questionNo: 6, code: '21.5.1' },
  { testNo: 135, questionNo: 7, code: '21.4.5' },
  { testNo: 135, questionNo: 8, code: '21.5.6' },
  { testNo: 136, questionNo: 1, code: '21.5.6' },
  { testNo: 136, questionNo: 2, code: '21.4.5' },
  { testNo: 136, questionNo: 3, code: '21.5.1' },
  { testNo: 136, questionNo: 4, code: '21.5.6' },
  { testNo: 136, questionNo: 5, code: '21.5.1' },
  { testNo: 136, questionNo: 6, code: '21.4.3' },
  { testNo: 136, questionNo: 7, code: '21.5.2' },
  { testNo: 136, questionNo: 8, code: '21.3' },
  { testNo: 136, questionNo: 9, code: '21.5.2' },
  { testNo: 137, questionNo: 1, code: '21.5.4' },
  { testNo: 137, questionNo: 2, code: '21.4.1' },
  { testNo: 137, questionNo: 3, code: '21.5.6' },
  { testNo: 137, questionNo: 4, code: '21.5.6' },
  { testNo: 137, questionNo: 5, code: '21.5.2' },
  { testNo: 137, questionNo: 6, code: '21.3' },
  { testNo: 137, questionNo: 7, code: '21.5.2' },
  { testNo: 138, questionNo: 1, code: '21.5.2' },
  { testNo: 138, questionNo: 2, code: '21.4.3' },
  { testNo: 138, questionNo: 3, code: '21.5.4' },
  { testNo: 138, questionNo: 4, code: '21.5.3' },
  { testNo: 138, questionNo: 5, code: '21.4.2' },
  { testNo: 138, questionNo: 6, code: '21.5.4' },
  { testNo: 138, questionNo: 7, code: '21.5.2' },
  { testNo: 139, questionNo: 1, code: '21.5.1' },
  { testNo: 139, questionNo: 2, code: '21.5.6' },
  { testNo: 139, questionNo: 3, code: '21.5.2' },
  { testNo: 139, questionNo: 4, code: '21.4.1' },
  { testNo: 139, questionNo: 5, code: '21.4.2' },
  { testNo: 139, questionNo: 6, code: '21.5.2' },
  { testNo: 139, questionNo: 7, code: '21.5.2' },
  { testNo: 140, questionNo: 1, code: '21.5.1' },
  { testNo: 140, questionNo: 2, code: '21.3' },
  { testNo: 140, questionNo: 3, code: '21.5.4' },
  { testNo: 140, questionNo: 4, code: '21.4.4' },
  { testNo: 140, questionNo: 5, code: '21.5.2' },
  { testNo: 140, questionNo: 6, code: '21.5.1' },
  { testNo: 140, questionNo: 7, code: '21.5.2' },
  { testNo: 141, questionNo: 1, code: '21.4.2' },
  { testNo: 141, questionNo: 2, code: '21.5.2' },
  { testNo: 141, questionNo: 3, code: '21.5.2' },
  { testNo: 141, questionNo: 4, code: '21.5.4' },
  { testNo: 141, questionNo: 5, code: '21.5.6' },
  { testNo: 141, questionNo: 6, code: '21.3' },
  { testNo: 141, questionNo: 7, code: '21.5.2' },
  { testNo: 141, questionNo: 8, code: '21.5.4' },
  { testNo: 142, questionNo: 1, code: '21.4.1' },
  { testNo: 142, questionNo: 2, code: '21.5.2' },
  { testNo: 142, questionNo: 3, code: '21.5.2' },
  { testNo: 142, questionNo: 4, code: '21.4.5' },
  { testNo: 142, questionNo: 5, code: '21.5.2' },
  { testNo: 142, questionNo: 6, code: '21.5.1' },
  { testNo: 142, questionNo: 7, code: '21.5.4' },
  { testNo: 143, questionNo: 1, code: '21.4.3' },
  { testNo: 143, questionNo: 2, code: '21.5.6' },
  { testNo: 143, questionNo: 3, code: '21.5.10' },
  { testNo: 143, questionNo: 4, code: '21.5.2' },
  { testNo: 143, questionNo: 5, code: '21.5.2' },
  { testNo: 143, questionNo: 6, code: '21.4.4' },
  { testNo: 143, questionNo: 7, code: '21.5.4' },
  { testNo: 144, questionNo: 1, code: '21.5.2' },
  { testNo: 144, questionNo: 2, code: '21.5.4' },
  { testNo: 144, questionNo: 3, code: '21.5.3' },
  { testNo: 144, questionNo: 4, code: '21.5.6' },
  { testNo: 144, questionNo: 5, code: '21.5.2' },
  { testNo: 144, questionNo: 6, code: '21.4.3' },
  { testNo: 144, questionNo: 7, code: '21.5.1' },
  { testNo: 144, questionNo: 8, code: '21.5.1' },
  { testNo: 145, questionNo: 1, code: '21.5.1' },
  { testNo: 145, questionNo: 2, code: '21.5.6' },
  { testNo: 145, questionNo: 3, code: '21.5.4' },
  { testNo: 145, questionNo: 4, code: '21.5.2' },
  { testNo: 145, questionNo: 5, code: '21.4.1' },
  { testNo: 145, questionNo: 6, code: '21.5.4' },
  { testNo: 145, questionNo: 7, code: '21.5.2' },
  { testNo: 146, questionNo: 1, code: '21.4.3' },
  { testNo: 146, questionNo: 2, code: '21.5.6' },
  { testNo: 146, questionNo: 3, code: '21.3' },
  { testNo: 146, questionNo: 4, code: '21.5.6' },
  { testNo: 146, questionNo: 5, code: '21.5.2' },
  { testNo: 146, questionNo: 6, code: '21.5.2' },
  { testNo: 146, questionNo: 7, code: '21.5.2' },
  { testNo: 146, questionNo: 8, code: '21.5.2' },
  { testNo: 147, questionNo: 1, code: '21.4.1' },
  { testNo: 147, questionNo: 2, code: '21.5.2' },
  { testNo: 147, questionNo: 3, code: '21.5.1' },
  { testNo: 147, questionNo: 4, code: '21.4.2' },
  { testNo: 147, questionNo: 5, code: '21.5.2' },
  { testNo: 147, questionNo: 6, code: '21.5.1' },
  { testNo: 147, questionNo: 7, code: '21.5.4' },
  { testNo: 147, questionNo: 8, code: '21.5.2' },
  { testNo: 148, questionNo: 1, code: '21.4.1' },
  { testNo: 148, questionNo: 2, code: '21.5.2' },
  { testNo: 148, questionNo: 3, code: '21.5.6' },
  { testNo: 148, questionNo: 4, code: '21.5.1' },
  { testNo: 148, questionNo: 5, code: '21.4.3' },
  { testNo: 148, questionNo: 6, code: '21.5.2' },
  { testNo: 148, questionNo: 7, code: '21.5.1' },
  { testNo: 149, questionNo: 1, code: '21.5.1' },
  { testNo: 149, questionNo: 2, code: '21.5.2' },
  { testNo: 149, questionNo: 3, code: '21.4.2' },
  { testNo: 149, questionNo: 4, code: '21.5.2' },
  { testNo: 149, questionNo: 5, code: '21.5.3' },
  { testNo: 149, questionNo: 6, code: '21.5.1' },
  { testNo: 149, questionNo: 7, code: '21.5.2' },
  { testNo: 149, questionNo: 8, code: '21.5.1' },
  { testNo: 150, questionNo: 1, code: '21.5.6' },
  { testNo: 150, questionNo: 2, code: '21.4.2' },
  { testNo: 150, questionNo: 3, code: '21.5.1' },
  { testNo: 150, questionNo: 4, code: '21.5.2' },
  { testNo: 150, questionNo: 5, code: '21.5.2' },
  { testNo: 150, questionNo: 6, code: '21.5.1' },
  { testNo: 150, questionNo: 7, code: '21.5.2' },
  { testNo: 151, questionNo: 1, code: '21.5.2' },
  { testNo: 151, questionNo: 2, code: '21.5.4' },
  { testNo: 151, questionNo: 3, code: '21.5.2' },
  { testNo: 151, questionNo: 4, code: '21.4.1' },
  { testNo: 151, questionNo: 5, code: '21.5.6' },
  { testNo: 151, questionNo: 6, code: '21.5.2' },
  { testNo: 151, questionNo: 7, code: '21.3' },
  { testNo: 152, questionNo: 1, code: '21.5.6' },
  { testNo: 152, questionNo: 2, code: '21.4.3' },
  { testNo: 152, questionNo: 3, code: '21.5.2' },
  { testNo: 152, questionNo: 4, code: '21.4.6' },
  { testNo: 152, questionNo: 5, code: '21.5.2' },
  { testNo: 152, questionNo: 6, code: '21.5.6' },
  { testNo: 152, questionNo: 7, code: '21.5.2' },
  { testNo: 152, questionNo: 8, code: '21.5.2' },
  { testNo: 153, questionNo: 1, code: '21.5.1' },
  { testNo: 153, questionNo: 2, code: '21.4.2' },
  { testNo: 153, questionNo: 3, code: '21.5.2' },
  { testNo: 153, questionNo: 4, code: '21.3' },
  { testNo: 153, questionNo: 5, code: '21.5.2' },
  { testNo: 153, questionNo: 6, code: '21.5.4' },
  { testNo: 153, questionNo: 7, code: '21.5.2' },
  { testNo: 154, questionNo: 1, code: '21.5.2' },
  { testNo: 154, questionNo: 2, code: '21.5.1' },
  { testNo: 154, questionNo: 3, code: '21.4.1' },
  { testNo: 154, questionNo: 4, code: '21.5.2' },
  { testNo: 154, questionNo: 5, code: '21.4.3' },
  { testNo: 154, questionNo: 6, code: '21.5.2' },
  { testNo: 154, questionNo: 7, code: '21.5.4' },
  { testNo: 154, questionNo: 8, code: '21.5.4' },
  { testNo: 155, questionNo: 1, code: '21.5.2' },
  { testNo: 155, questionNo: 2, code: '21.5.1' },
  { testNo: 155, questionNo: 3, code: '21.5.2' },
  { testNo: 155, questionNo: 4, code: '21.5.1' },
  { testNo: 155, questionNo: 5, code: '21.5.1' },
  { testNo: 155, questionNo: 6, code: '21.5.4' },
  { testNo: 155, questionNo: 7, code: '21.4.2' },
  { testNo: 156, questionNo: 1, code: '21.5.2' },
  { testNo: 156, questionNo: 2, code: '21.4.3' },
  { testNo: 156, questionNo: 3, code: '21.5.1' },
  { testNo: 156, questionNo: 4, code: '21.4.2' },
  { testNo: 156, questionNo: 5, code: '21.5.10' },
  { testNo: 156, questionNo: 6, code: '21.4.6' },
  { testNo: 156, questionNo: 7, code: '21.5.2' },
  { testNo: 156, questionNo: 8, code: '21.5.1' },
  { testNo: 157, questionNo: 1, code: '21.5.6' },
  { testNo: 157, questionNo: 2, code: '21.5.2' },
  { testNo: 157, questionNo: 3, code: '21.5.2' },
  { testNo: 157, questionNo: 4, code: '21.3' },
  { testNo: 157, questionNo: 5, code: '21.5.1' },
  { testNo: 157, questionNo: 6, code: '21.4.1' },
  { testNo: 157, questionNo: 7, code: '21.5.4' },
  { testNo: 158, questionNo: 1, code: '21.5.2' },
  { testNo: 158, questionNo: 2, code: '21.5.4' },
  { testNo: 158, questionNo: 3, code: '21.5.6' },
  { testNo: 158, questionNo: 4, code: '21.5.6' },
  { testNo: 158, questionNo: 5, code: '21.5.3' },
  { testNo: 158, questionNo: 6, code: '21.4.2' },
  { testNo: 158, questionNo: 7, code: '21.5.2' },
  { testNo: 159, questionNo: 1, code: '21.5.4' },
  { testNo: 159, questionNo: 2, code: '21.4.3' },
  { testNo: 159, questionNo: 3, code: '21.5.2' },
  { testNo: 159, questionNo: 4, code: '21.5.2' },
  { testNo: 159, questionNo: 5, code: '21.5.2' },
  { testNo: 159, questionNo: 6, code: '21.4.1' },
  { testNo: 159, questionNo: 7, code: '21.5.2' },
  { testNo: 159, questionNo: 8, code: '21.5.1' },
  { testNo: 160, questionNo: 1, code: '21.4.2' },
  { testNo: 160, questionNo: 2, code: '21.5.1' },
  { testNo: 160, questionNo: 3, code: '21.4.5' },
  { testNo: 160, questionNo: 4, code: '21.5.2' },
  { testNo: 160, questionNo: 5, code: '21.5.6' },
  { testNo: 160, questionNo: 6, code: '21.5.4' },
  { testNo: 160, questionNo: 7, code: '21.5.2' },
  { testNo: 160, questionNo: 8, code: '21.5.4' },
];

async function main() {
  console.log(`Resetting outcomes and mappings for "${BOOK_TITLE}"`);
  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found`);
  }

  const bookId = book.id;

  const deletedMappings = await prisma.questionOutcome.deleteMany({
    where: {
      question: {
        test: {
          section: {
            bookId,
          },
        },
      },
    },
  });

  const deletedOutcomes = await prisma.learningOutcome.deleteMany({
    where: { bookId },
  });

  await prisma.learningOutcome.createMany({
    data: OUTCOMES.map((o) => ({
      code: o.code,
      name: o.name,
      category: o.category,
      bookId,
    })),
  });

  const outcomeMap = new Map(
    (
      await prisma.learningOutcome.findMany({
        where: { bookId },
        select: { id: true, code: true },
      })
    ).map((o) => [o.code, o.id]),
  );

  const rows = RAW_MAPPINGS.filter((row) => row.testNo <= MAX_TEST_NO);
  const orderedTests = await prisma.test.findMany({
    where: {
      section: { bookId },
    },
    select: { id: true },
    orderBy: [{ createdAt: 'asc' }],
  });
  const testIdByOrdinal = new Map<number, string>(
    orderedTests.map((t, idx) => [idx + 1, t.id]),
  );

  let backfilledQuestions = 0;
  // Backfill all missing questions based on RAW_MAPPINGS (each question that has a mapping must exist)
  const maxQByTestNo = new Map<number, number>();
  for (const row of rows) {
    const current = maxQByTestNo.get(row.testNo) ?? 0;
    if (row.questionNo > current) maxQByTestNo.set(row.testNo, row.questionNo);
  }

  for (const [testNo, maxQ] of maxQByTestNo) {
    const testId = testIdByOrdinal.get(testNo);
    if (!testId) continue;

    const answers = ANSWER_KEYS[testNo] ?? [];
    for (let qNo = 1; qNo <= maxQ; qNo++) {
      const correctAnswerIndex = qNo <= answers.length ? answers[qNo - 1] : 0;
      const exists = await prisma.question.findFirst({
        where: { testId, orderIndex: qNo - 1 },
        select: { id: true },
      });
      if (!exists) {
        await prisma.question.create({
          data: {
            text: '',
            optionA: 'A',
            optionB: 'B',
            optionC: 'C',
            optionD: 'D',
            optionE: 'E',
            correctAnswerIndex,
            orderIndex: qNo - 1,
            testId,
          },
        });
        backfilledQuestions++;
      } else {
        await prisma.question.update({
          where: { id: exists.id },
          data: { correctAnswerIndex },
        });
      }
    }
  }

  const missingTests = new Set<number>();
  let skipped = 0;
  let createdMappings = 0;

  for (const row of rows) {
    const outcomeId = outcomeMap.get(row.code);
    if (!outcomeId) {
      skipped++;
      continue;
    }

    const testId = testIdByOrdinal.get(row.testNo);
    if (!testId) {
      missingTests.add(row.testNo);
      skipped++;
      continue;
    }

    const question = await prisma.question.findFirst({
      where: {
        testId,
        orderIndex: row.questionNo - 1,
      },
      select: { id: true },
    });

    if (!question) {
      skipped++;
      continue;
    }

    await prisma.questionOutcome.upsert({
      where: {
        questionId_learningOutcomeId: {
          questionId: question.id,
          learningOutcomeId: outcomeId,
        },
      },
      update: {},
      create: {
        questionId: question.id,
        learningOutcomeId: outcomeId,
      },
    });
    createdMappings++;
  }

  const totalOutcomes = await prisma.learningOutcome.count({ where: { bookId } });
  const totalMappings = await prisma.questionOutcome.count({
    where: {
      question: {
        test: {
          section: {
            bookId,
          },
        },
      },
    },
  });

  console.log('\n=== VALIDATION ===');
  console.log(`Removed mappings: ${deletedMappings.count}`);
  console.log(`Removed outcomes: ${deletedOutcomes.count}`);
  console.log(`Outcomes: ${totalOutcomes}`);
  console.log(`Mappings created from input: ${createdMappings}`);
  console.log(`Backfilled questions: ${backfilledQuestions}`);
  console.log(`Rows skipped: ${skipped}`);
  if (missingTests.size > 0) {
    console.log(`Missing tests: ${Array.from(missingTests).sort((a, b) => a - b).join(', ')}`);
  }
  console.log(`Mappings: ${totalMappings}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
