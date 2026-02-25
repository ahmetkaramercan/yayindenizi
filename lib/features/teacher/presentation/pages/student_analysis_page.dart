import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/teacher_dashboard_provider.dart';

class TeacherStudentAnalysisPage extends ConsumerWidget {
  const TeacherStudentAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(teacherDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Analizi'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Öğrenci Arama
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: AppColors.surface,
            child: AppTextField(
              label: 'Öğrenci Ara',
              hint: 'Öğrenci adı veya email ile ara',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                // TODO: Öğrenci arama
              },
            ),
          ),
          // Bağlı Öğrenciler - tıklanınca profil açılır (dashboard ile aynı)
          Expanded(
            child: dashboardState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : dashboardState.error != null
                    ? Center(
                        child: Text(
                          dashboardState.error!,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : dashboardState.students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Henüz bağlı öğrenciniz yok',
                                  style: AppTextStyles.body1.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.read(teacherDashboardProvider.notifier).loadStudents();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.paddingM),
                              itemCount: dashboardState.students.length,
                              itemBuilder: (context, index) {
                                final student = dashboardState.students[index];
                                return AppCard(
                                  margin: const EdgeInsets.only(
                                    bottom: AppConstants.paddingS,
                                  ),
                                  onTap: () {
                                    context.push(
                                      '/teacher/student-detail',
                                      extra: student.id ?? '',
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primary,
                                            child: Text(
                                              student.adSoyad.isNotEmpty
                                                  ? student.adSoyad[0].toUpperCase()
                                                  : 'Ö',
                                              style: AppTextStyles.h6.copyWith(
                                                color: AppColors.textOnPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppConstants.paddingM),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student.adSoyad,
                                                  style: AppTextStyles.h6.copyWith(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  student.email,
                                                  style: AppTextStyles.body2.copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: AppColors.textSecondary,
                                          ),
                                        ],
                                      ),
                                      if (student.locationDisplay != null) ...[
                                        const SizedBox(height: AppConstants.paddingS),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              student.locationDisplay!,
                                              style: AppTextStyles.caption.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

