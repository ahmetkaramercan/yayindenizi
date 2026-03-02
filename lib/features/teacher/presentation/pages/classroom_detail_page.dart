import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/classroom_detail_provider.dart';
import '../providers/teacher_dashboard_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/classroom_repository.dart';

class ClassroomDetailPage extends ConsumerWidget {
  final String classroomId;

  const ClassroomDetailPage({super.key, required this.classroomId});

  Future<void> _showRenameDialog(
      BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sınıf Adını Değiştir'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Sınıf Adı'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != currentName) {
                await sl<ClassroomRepository>()
                    .updateClassroom(classroomId, name);
                if (ctx.mounted) Navigator.of(ctx).pop();
                ref
                    .read(classroomDetailProvider(classroomId).notifier)
                    .loadDetail();
                ref
                    .read(teacherDashboardProvider.notifier)
                    .loadClassrooms();
              } else {
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _confirmDeleteClassroom(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sınıfı Sil'),
        content: const Text(
            'Bu sınıfı silmek istediğinizden emin misiniz? Tüm öğrenci kayıtları da silinecek.'),
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
      await ref
          .read(teacherDashboardProvider.notifier)
          .deleteClassroom(classroomId);
      if (context.mounted) context.pop();
    }
  }

  Future<void> _confirmRemoveStudent(
      BuildContext context, WidgetRef ref, String studentId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Öğrenciyi Çıkar'),
        content: Text('$name adlı öğrenciyi sınıftan çıkarmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(classroomDetailProvider(classroomId).notifier)
          .removeStudent(studentId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classroomDetailProvider(classroomId));
    final classroom = state.classroom;

    return Scaffold(
      appBar: AppBar(
        title: Text(classroom?.name ?? 'Sınıf Detayı'),
        actions: [
          if (classroom != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Sınıfı Yeniden Adlandır',
              onPressed: () =>
                  _showRenameDialog(context, ref, classroom.name),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Sınıfı Sil',
              onPressed: () => _confirmDeleteClassroom(context, ref),
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(classroomDetailProvider(classroomId).notifier).loadDetail();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Sınıf Bilgi Kartı
            if (classroom != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              radius: 24,
                              child: Icon(Icons.class_outlined,
                                  color: AppColors.textOnPrimary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    classroom.name,
                                    style: AppTextStyles.h5.copyWith(
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
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Row(
                          children: [
                            Text(
                              'Sınıf Kodu:',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: classroom.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sınıf kodu kopyalandı'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          AppColors.accent.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      classroom.code,
                                      style: AppTextStyles.body1.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.copy,
                                        size: 14,
                                        color:
                                            AppColors.accent.withOpacity(0.7)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Öğrenciler bu kodu girerek sınıfa katılabilir',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Öğrenciler Başlık
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM),
                child: Text(
                  'Öğrenciler',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.paddingS)),

            // Öğrenci Listesi
            if (state.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (state.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: AppCard(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (state.students.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: AppCard(
                    child: Column(
                      children: [
                        Icon(Icons.person_off_outlined,
                            color: AppColors.textSecondary, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz bu sınıfta öğrenci yok',
                          style: AppTextStyles.body1.copyWith(
                              color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Öğrenciler sınıf kodunu girerek katılabilir',
                          style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = state.students[index];
                      return AppCard(
                        margin: const EdgeInsets.only(
                            bottom: AppConstants.paddingS),
                        onTap: () {
                          context.push(
                            '/teacher/student-detail',
                            extra: {
                              'studentId': student.id ?? '',
                              'classroomId': classroomId,
                            },
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                student.adSoyad.isNotEmpty
                                    ? student.adSoyad[0].toUpperCase()
                                    : 'Ö',
                                style: AppTextStyles.h6.copyWith(
                                    color: AppColors.textOnPrimary),
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
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.person_remove_outlined,
                                  color: AppColors.error.withOpacity(0.7)),
                              onPressed: () => _confirmRemoveStudent(
                                  context, ref, student.id ?? '', student.adSoyad),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      );
                    },
                    childCount: state.students.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
