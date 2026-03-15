import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../teacher/domain/entities/classroom.dart';
import '../providers/student_dashboard_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/providers/invalidate_user_providers.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../providers/add_teacher_provider.dart';

class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  final _classroomCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentDashboardProvider.notifier).loadClassrooms();
    });
  }

  @override
  void dispose() {
    _classroomCodeController.dispose();
    super.dispose();
  }

  void _showJoinClassroomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınıfa Katıl'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Sınıf Kodu',
              hint: 'AB3X7KP2',
              controller: _classroomCodeController,
              prefixIcon: const Icon(Icons.class_outlined),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _classroomCodeController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          AppButton(
            text: 'Katıl',
            onPressed: () {
              final code = _classroomCodeController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                ref.read(addTeacherProvider.notifier).addTeacher(code);
                _classroomCodeController.clear();
                Navigator.of(context).pop();
              }
            },
            type: AppButtonType.primary,
          ),
        ],
      ),
    ).then((_) {
      _classroomCodeController.clear();
    });
  }

  void _showLeaveClassroomDialog(
      BuildContext context, WidgetRef ref, Classroom classroom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınıftan Ayrıl'),
        content: Text(
            '${classroom.name} sınıfından ayrılmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          AppButton(
            text: 'Ayrıl',
            onPressed: () {
              ref
                  .read(studentDashboardProvider.notifier)
                  .leaveClassroom(classroom.id);
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

    // Başarılı sınıfa katılma mesajı
    if (addTeacherState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showSnackBar(
          'Sınıfa başarıyla katıldınız!',
          backgroundColor: AppColors.success,
        );
        ref.read(addTeacherProvider.notifier).reset();
        ref.read(studentDashboardProvider.notifier).loadClassrooms();
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
              ref.read(invalidateUserProvidersProvider)();
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
          ref.read(studentDashboardProvider.notifier).loadClassrooms();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sınıfa Katıl Butonu
              AppButton(
                text: 'Sınıfa Katıl',
                icon: Icons.add_circle_outline,
                onPressed: _showJoinClassroomDialog,
                isFullWidth: true,
                type: AppButtonType.primary,
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Sınıflarım Listesi
              Text(
                'Sınıflarım',
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
              else if (dashboardState.classrooms.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.class_outlined,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz bir sınıfa katılmadınız',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sınıf kodunuzu girerek sınıfa katılabilirsiniz',
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
                      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              classroom.name.isNotEmpty
                                  ? classroom.name[0].toUpperCase()
                                  : 'S',
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
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: classroom.code));
                              context.showSnackBar(
                                'Sınıf kodu kopyalandı: ${classroom.code}',
                                backgroundColor: AppColors.success,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    classroom.code,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.copy,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.exit_to_app),
                            color: AppColors.error,
                            onPressed: () => _showLeaveClassroomDialog(
                              context,
                              ref,
                              classroom,
                            ),
                            tooltip: 'Sınıftan Ayrıl',
                          ),
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
