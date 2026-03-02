import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/teacher_dashboard_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/providers/invalidate_user_providers.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  Future<void> _showCreateClassroomDialog(
      BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Sınıf Oluştur'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Sınıf Adı',
            hintText: 'Örn: 9-A Türkçe',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(teacherDashboardProvider.notifier)
                    .addClassroom(name);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(teacherDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğretmen Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.push('/teacher/student-analysis'),
            tooltip: 'Öğrenci Analizi',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              ref.read(invalidateUserProvidersProvider)();
              await sl<AuthRepository>().logout();
              if (context.mounted) context.pushReplacement('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateClassroomDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Sınıf Oluştur'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(teacherDashboardProvider.notifier).loadClassrooms();
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
                                ? dashboardState.teacher!.adSoyad[0]
                                    .toUpperCase()
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
              // Sınıflarım Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sınıflarım',
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
                      '${dashboardState.classrooms.length}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingM),
              // Sınıf Listesi
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
                      Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        dashboardState.error!,
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (dashboardState.classrooms.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      Icon(Icons.class_outlined,
                          color: AppColors.textSecondary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz sınıf oluşturmadınız',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sağ alttaki "Sınıf Oluştur" butonuna basarak ilk sınıfınızı oluşturun',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...dashboardState.classrooms.map((classroom) => AppCard(
                      margin:
                          const EdgeInsets.only(bottom: AppConstants.paddingS),
                      onTap: () {
                        context.push('/teacher/classroom/${classroom.id}');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.class_outlined,
                                    color: AppColors.textOnPrimary),
                              ),
                              const SizedBox(width: AppConstants.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      classroom.name,
                                      style: AppTextStyles.h6.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${classroom.studentCount} öğrenci',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Sınıf kodu chip'i (kopyalanabilir)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: classroom.code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Sınıf kodu kopyalandı'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.accent
                                            .withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        classroom.code,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.copy,
                                          size: 12,
                                          color: AppColors.accent
                                              .withOpacity(0.7)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ],
                      ),
                    )),
              // FAB için boşluk bırak
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
