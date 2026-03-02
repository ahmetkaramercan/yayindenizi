import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cards/app_card.dart';
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
        title: const Text('Sınıf Analizi'),
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
              ? Center(
                  child: Text(
                    dashboardState.error!,
                    style: AppTextStyles.body1.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                )
              : dashboardState.classrooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.class_outlined,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz sınıf oluşturmadınız',
                            style: AppTextStyles.body1
                                .copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref
                            .read(teacherDashboardProvider.notifier)
                            .loadClassrooms();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        itemCount: dashboardState.classrooms.length,
                        itemBuilder: (context, index) {
                          final classroom = dashboardState.classrooms[index];
                          return AppCard(
                            margin: const EdgeInsets.only(
                                bottom: AppConstants.paddingS),
                            onTap: () {
                              context.push(
                                  '/teacher/classroom/${classroom.id}');
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    classroom.name.isNotEmpty
                                        ? classroom.name[0].toUpperCase()
                                        : 'S',
                                    style: AppTextStyles.h6
                                        .copyWith(color: AppColors.textOnPrimary),
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
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: AppColors.textSecondary),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
