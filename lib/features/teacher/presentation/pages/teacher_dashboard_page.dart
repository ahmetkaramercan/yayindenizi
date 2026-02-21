import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/teacher_dashboard_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(teacherDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğretmen Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              context.push('/teacher/student-analysis');
            },
            tooltip: 'Öğrenci Analizi',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await sl<AuthRepository>().logout();
              if (context.mounted) {
                context.pushReplacement('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(teacherDashboardProvider.notifier).loadStudents();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Öğretmen Bilgileri Kartı
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            dashboardState.teacher?.adSoyad.isNotEmpty == true
                                ? dashboardState.teacher!.adSoyad[0].toUpperCase()
                                : 'T',
                            style: AppTextStyles.h4.copyWith(
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
                                dashboardState.teacher?.adSoyad ?? 'Öğretmen',
                                style: AppTextStyles.h5.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dashboardState.teacher?.email ?? '',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            dashboardState.teacher?.ogretmenKodu ?? '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (dashboardState.teacher?.okul != null) ...[
                      const SizedBox(height: AppConstants.paddingM),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dashboardState.teacher!.okul!,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Bağlı Öğrenciler Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bağlı Öğrenciler',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${dashboardState.students.length}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingM),
              // Öğrenci Listesi
              if (dashboardState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (dashboardState.error != null)
                AppCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dashboardState.error!,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (dashboardState.students.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz bağlı öğrenciniz yok',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Öğrenciler öğretmen kodunuzu kullanarak size bağlanabilir',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...dashboardState.students.map((student) => AppCard(
                      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
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
                          if (student.il != null || student.ilce != null) ...[
                            const SizedBox(height: AppConstants.paddingS),
                            Row(
                              children: [
                                if (student.il != null) ...[
                                  Icon(
                                    Icons.location_city_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    student.il!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                if (student.il != null &&
                                    student.ilce != null) ...[
                                  const SizedBox(width: 16),
                                ],
                                if (student.ilce != null) ...[
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    student.ilce!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

