import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../teacher/domain/entities/teacher.dart';
import '../providers/student_dashboard_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../providers/add_teacher_provider.dart';

class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  final _teacherCodeController = TextEditingController();
  bool _showAddTeacherDialog = false;

  @override
  void dispose() {
    _teacherCodeController.dispose();
    super.dispose();
  }

  void _showAddTeacherDialogFunc() {
    setState(() {
      _showAddTeacherDialog = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğretmen Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Öğretmen Kodu',
              hint: 'TCH123456',
              controller: _teacherCodeController,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showAddTeacherDialog = false;
              });
              _teacherCodeController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          AppButton(
            text: 'Ekle',
            onPressed: () {
              final code = _teacherCodeController.text.trim();
              if (code.isNotEmpty) {
                ref.read(addTeacherProvider.notifier).addTeacher(code);
                _teacherCodeController.clear();
                Navigator.of(context).pop();
                setState(() {
                  _showAddTeacherDialog = false;
                });
              }
            },
            type: AppButtonType.primary,
          ),
        ],
      ),
    ).then((_) {
      setState(() {
        _showAddTeacherDialog = false;
      });
      _teacherCodeController.clear();
    });
  }

  void _showRemoveTeacherDialog(
      BuildContext context, WidgetRef ref, Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğretmeni Kaldır'),
        content: Text(
            '${teacher.adSoyad} adlı öğretmeni listeden çıkarmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          AppButton(
            text: 'Kaldır',
            onPressed: () {
              ref
                  .read(studentDashboardProvider.notifier)
                  .removeTeacher(teacher.id ?? '');
              Navigator.of(context).pop();
            },
            type: AppButtonType.danger,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(studentDashboardProvider);
    final addTeacherState = ref.watch(addTeacherProvider);

    // Başarılı öğretmen ekleme mesajı
    if (addTeacherState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showSnackBar(
          'Öğretmen başarıyla eklendi!',
          backgroundColor: AppColors.success,
        );
        ref.read(addTeacherProvider.notifier).reset();
        ref.read(studentDashboardProvider.notifier).loadTeachers();
      });
    }

    // Hata mesajı
    if (addTeacherState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showSnackBar(
          addTeacherState.error!,
          backgroundColor: AppColors.error,
        );
        ref.read(addTeacherProvider.notifier).reset();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Paneli'),
        actions: [
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
          ref.read(studentDashboardProvider.notifier).loadTeachers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Öğretmen Ekle Butonu
              AppButton(
                text: 'Öğretmen Ekle',
                icon: Icons.person_add,
                onPressed: _showAddTeacherDialogFunc,
                isFullWidth: true,
                type: AppButtonType.primary,
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Bağlı Öğretmenler Listesi
              Text(
                'Bağlı Öğretmenlerim',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
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
              else if (dashboardState.teachers.isEmpty)
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
                        'Henüz bağlı öğretmeniniz yok',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Öğretmen eklemek için yukarıdaki butona tıklayın',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...dashboardState.teachers.map((teacher) => AppCard(
                      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  teacher.adSoyad.isNotEmpty
                                      ? teacher.adSoyad[0].toUpperCase()
                                      : 'T',
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
                                      teacher.adSoyad,
                                      style: AppTextStyles.h6.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      teacher.email,
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
                                  color: AppColors.primaryLight.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  teacher.ogretmenKodu,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.error,
                                onPressed: () => _showRemoveTeacherDialog(
                                  context,
                                  ref,
                                  teacher,
                                ),
                                tooltip: 'Öğretmeni Kaldır',
                              ),
                            ],
                          ),
                          if (teacher.il != null || teacher.ilce != null) ...[
                            const SizedBox(height: AppConstants.paddingS),
                            Row(
                              children: [
                                if (teacher.il != null) ...[
                                  Icon(
                                    Icons.location_city_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    teacher.il!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                if (teacher.il != null &&
                                    teacher.ilce != null) ...[
                                  const SizedBox(width: 16),
                                ],
                                if (teacher.ilce != null) ...[
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    teacher.ilce!,
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

