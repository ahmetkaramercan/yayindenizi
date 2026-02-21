import { Module } from '@nestjs/common';
import { TeacherStudentService } from './teacher-student.service';
import { TeacherStudentController } from './teacher-student.controller';

@Module({
  controllers: [TeacherStudentController],
  providers: [TeacherStudentService],
  exports: [TeacherStudentService],
})
export class TeacherStudentModule {}
