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

class TeacherDashboardPage extends ConsumerStatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  ConsumerState<TeacherDashboardPage> createState() =>
      _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends ConsumerState<TeacherDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherDashboardProvider.notifier).loadTeacherInfo();
      ref.read(teacherDashboardProvider.notifier).loadClassrooms();
    });
  }

  Future<void> _showCreateClassroomDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => const _ClassroomNameDialog(
        title: 'Yeni Sınıf Oluştur',
        hint: 'Örn: 9-A Türkçe',
        confirmLabel: 'Oluştur',
      ),
    );
    if (name != null && mounted) {
      ref.read(teacherDashboardProvider.notifier).addClassroom(name);
    }
  }

  Future<void> _showRenameDialog(String classroomId, String currentName) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _ClassroomNameDialog(
        title: 'Sınıfı Adlandır',
        initialValue: currentName,
        confirmLabel: 'Kaydet',
      ),
    );
    if (name != null && name.isNotEmpty && name != currentName && mounted) {
      await ref
          .read(teacherDashboardProvider.notifier)
          .renameClassroom(classroomId, name);
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hesabımı Sil'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        ref.read(invalidateUserProvidersProvider)();
        await sl<AuthRepository>().deleteAccount();
        if (mounted) context.pushReplacement('/login');
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hesap silinemedi. Lütfen tekrar deneyin.')),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteClassroom(String classroomId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sınıfı Sil'),
        content: Text(
            '"$name" sınıfını silmek istediğinizden emin misiniz? Tüm öğrenci kayıtları da silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(teacherDashboardProvider.notifier).deleteClassroom(classroomId);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                ref.read(invalidateUserProvidersProvider)();
                await sl<AuthRepository>().logout();
                if (context.mounted) context.pushReplacement('/login');
              } else if (value == 'delete') {
                await _showDeleteAccountDialog();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Hesabımı Sil', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateClassroomDialog,
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
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
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
                      child: Row(
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
                              context.showSnackBar('Sınıf kodu kopyalandı');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.4)),
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
                                          .withValues(alpha: 0.7)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // 3-nokta menüsü: Adlandır + Sil
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'rename') {
                                _showRenameDialog(classroom.id, classroom.name);
                              } else if (value == 'delete') {
                                _confirmDeleteClassroom(
                                    classroom.id, classroom.name);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Adlandır'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 18, color: AppColors.error),
                                    const SizedBox(width: 8),
                                    Text('Sil',
                                        style:
                                            TextStyle(color: AppColors.error)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              // FAB için boşluk
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sınıf adı dialog widget'ı ────────────────────────────────────────────────
class _ClassroomNameDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String? hint;
  final String confirmLabel;

  const _ClassroomNameDialog({
    required this.title,
    this.initialValue,
    this.hint,
    required this.confirmLabel,
  });

  @override
  State<_ClassroomNameDialog> createState() => _ClassroomNameDialogState();
}

class _ClassroomNameDialogState extends State<_ClassroomNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Sınıf Adı',
          hintText: widget.hint,
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (value) {
          final name = value.trim();
          if (name.isNotEmpty) Navigator.of(context).pop(name);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) Navigator.of(context).pop(name);
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
