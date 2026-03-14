import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '@/app.module';
import { PrismaService } from '@/prisma/prisma.service';
import { TransformInterceptor } from '@/common/interceptors/transform.interceptor';
import { AllExceptionsFilter } from '@/common/filters/http-exception.filter';

describe('Öğretmen/Öğrenci Kaydı ve Sınıf Sistemi (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  const SUFFIX = Date.now().toString();
  const TEST_TEACHER_EMAIL = `teacher_${SUFFIX}@test.com`;
  const TEST_STUDENT_EMAIL = `student_${SUFFIX}@test.com`;
  const TEST_PASSWORD = 'Test123';

  let teacherToken: string;
  let studentToken: string;
  let cityId: string;
  let districtId: string;
  let classroomId: string;
  let classroomCode: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    app.useGlobalFilters(new AllExceptionsFilter());
    app.useGlobalInterceptors(new TransformInterceptor());
    await app.init();

    prisma = moduleFixture.get(PrismaService);

    // Geçerli şehir ve ilçe ID'lerini al
    const citiesRes = await request(app.getHttpServer())
      .get('/api/v1/cities')
      .expect(200);
    cityId = citiesRes.body.data[0].id;

    const districtsRes = await request(app.getHttpServer())
      .get('/api/v1/cities/districts')
      .query({ cityId })
      .expect(200);
    districtId = districtsRes.body.data[0].id;
  });

  afterAll(async () => {
    // Test verilerini temizle
    await prisma.user.deleteMany({
      where: { email: { in: [TEST_TEACHER_EMAIL, TEST_STUDENT_EMAIL] } },
    });
    await app.close();
  });

  // ─── Auth ──────────────────────────────────────────────────────────────────

  describe('Auth', () => {
    it('geçersiz kimlik bilgileriyle giriş reddedilmeli', () => {
      return request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ email: 'nonexistent@test.com', password: 'wrongpassword' })
        .expect(401);
    });
  });

  // ─── Öğretmen Kaydı ────────────────────────────────────────────────────────

  describe('Öğretmen Kaydı', () => {
    it('öğretmen başarıyla kaydedilmeli', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/register/teacher')
        .send({
          email: TEST_TEACHER_EMAIL,
          password: TEST_PASSWORD,
          adSoyad: 'Test Öğretmen',
          cityId,
          districtId,
          okul: 'Test Okulu',
        })
        .expect(201);

      expect(res.body.data).toHaveProperty('accessToken');
      expect(res.body.data).toHaveProperty('refreshToken');
      expect(res.body.data.user.role).toBe('TEACHER');
      expect(res.body.data.user.email).toBe(TEST_TEACHER_EMAIL);
      teacherToken = res.body.data.accessToken;
    });

    it('aynı email ile tekrar kayıt olunamamalı', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/auth/register/teacher')
        .send({
          email: TEST_TEACHER_EMAIL,
          password: TEST_PASSWORD,
          adSoyad: 'Test Öğretmen 2',
          cityId,
          districtId,
          okul: 'Test Okulu',
        })
        .expect(409);
    });

    it('eksik alanlarla kayıt olunamamalı', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/auth/register/teacher')
        .send({ email: 'missing@test.com', password: TEST_PASSWORD })
        .expect(400);
    });

    it('öğretmen kendi profilini görebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/users/teacher/me')
        .set('Authorization', `Bearer ${teacherToken}`)
        .expect(200);

      expect(res.body.data.email).toBe(TEST_TEACHER_EMAIL);
      expect(res.body.data.role).toBe('TEACHER');
    });
  });

  // ─── Öğrenci Kaydı ─────────────────────────────────────────────────────────

  describe('Öğrenci Kaydı', () => {
    it('öğrenci başarıyla kaydedilmeli', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/register/student')
        .send({
          email: TEST_STUDENT_EMAIL,
          password: TEST_PASSWORD,
          adSoyad: 'Test Öğrenci',
          cityId,
          districtId,
        })
        .expect(201);

      expect(res.body.data).toHaveProperty('accessToken');
      expect(res.body.data).toHaveProperty('refreshToken');
      expect(res.body.data.user.role).toBe('STUDENT');
      expect(res.body.data.user.email).toBe(TEST_STUDENT_EMAIL);
      studentToken = res.body.data.accessToken;
    });

    it('aynı email ile tekrar kayıt olunamamalı', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/auth/register/student')
        .send({
          email: TEST_STUDENT_EMAIL,
          password: TEST_PASSWORD,
          adSoyad: 'Test Öğrenci 2',
          cityId,
          districtId,
        })
        .expect(409);
    });

    it('eksik alanlarla kayıt olunamamalı', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/auth/register/student')
        .send({ email: 'missing@test.com', password: TEST_PASSWORD })
        .expect(400);
    });

    it('öğrenci kendi profilini görebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/users/student/me')
        .set('Authorization', `Bearer ${studentToken}`)
        .expect(200);

      expect(res.body.data.email).toBe(TEST_STUDENT_EMAIL);
      expect(res.body.data.role).toBe('STUDENT');
    });
  });

  // ─── Sınıf Sistemi ──────────────────────────────────────────────────────────

  describe('Sınıf Sistemi', () => {
    it('öğretmen sınıf oluşturabilmeli', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/classrooms')
        .set('Authorization', `Bearer ${teacherToken}`)
        .send({ name: 'Test Sınıfı' })
        .expect(201);

      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data).toHaveProperty('code');
      expect(res.body.data.name).toBe('Test Sınıfı');
      expect(res.body.data._count.students).toBe(0);
      classroomId = res.body.data.id;
      classroomCode = res.body.data.code;
    });

    it('öğrenci sınıf oluşturamamalı', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/classrooms')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ name: 'Öğrenci Sınıfı' })
        .expect(403);
    });

    it('öğretmen kendi sınıflarını listeleyebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/classrooms')
        .set('Authorization', `Bearer ${teacherToken}`)
        .expect(200);

      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.some((c: any) => c.id === classroomId)).toBe(true);
    });

    it('öğrenci sınıf kodunu kullanarak sınıfa katılabilmeli', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/classrooms/join')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ code: classroomCode })
        .expect(201);

      expect(res.body.data).toHaveProperty('message');
      expect(res.body.data.classroom.id).toBe(classroomId);
    });

    it('öğrenci aynı sınıfa iki kez katılamamalı', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/classrooms/join')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ code: classroomCode })
        .expect(409);
    });

    it('yanlış kodla sınıfa katılınamamalı', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/classrooms/join')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ code: 'XXXXXXXX' })
        .expect(404);
    });

    it('öğrenci kendi sınıflarını listeleyebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/classrooms/my-classrooms')
        .set('Authorization', `Bearer ${studentToken}`)
        .expect(200);

      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.some((c: any) => c.id === classroomId)).toBe(true);
    });

    it('öğretmen sınıf detayını ve öğrencileri görebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/v1/classrooms/${classroomId}`)
        .set('Authorization', `Bearer ${teacherToken}`)
        .expect(200);

      expect(res.body.data).toHaveProperty('classroom');
      expect(res.body.data).toHaveProperty('students');
      expect(res.body.data.students.length).toBe(1);
      expect(res.body.data.total).toBe(1);
    });

    it('sınıf kodu yenilenebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/v1/classrooms/${classroomId}/regenerate-code`)
        .set('Authorization', `Bearer ${teacherToken}`)
        .expect(201);

      expect(res.body.data).toHaveProperty('code');
      expect(res.body.data.code).not.toBe(classroomCode);
      classroomCode = res.body.data.code;
    });

    it('öğrenci sınıftan ayrılabilmeli', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/classrooms/my-classrooms/${classroomId}`)
        .set('Authorization', `Bearer ${studentToken}`)
        .expect(200);

      expect(res.body.data).toHaveProperty('message');
    });

    it('ayrıldıktan sonra sınıf listesinde görünmemeli', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/classrooms/my-classrooms')
        .set('Authorization', `Bearer ${studentToken}`)
        .expect(200);

      expect(res.body.data.every((c: any) => c.id !== classroomId)).toBe(true);
    });

    it('öğretmen sınıfı güncelleyebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/v1/classrooms/${classroomId}`)
        .set('Authorization', `Bearer ${teacherToken}`)
        .send({ name: 'Güncellenmiş Sınıf' })
        .expect(200);

      expect(res.body.data.name).toBe('Güncellenmiş Sınıf');
    });

    it('öğretmen sınıfı silebilmeli', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/classrooms/${classroomId}`)
        .set('Authorization', `Bearer ${teacherToken}`)
        .expect(200);

      expect(res.body.data).toHaveProperty('message');
    });
  });
});
