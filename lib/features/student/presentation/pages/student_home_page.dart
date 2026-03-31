import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/book_card.dart';
import '../widgets/gunun_bilgisi_dialog.dart';
import '../providers/student_home_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/providers/invalidate_user_providers.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class StudentHomePage extends ConsumerWidget {
  const StudentHomePage({super.key});

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz. Tüm verileriniz (test sonuçları, istatistikler) kalıcı olarak silinecektir.',
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
    if (confirmed == true && context.mounted) {
      try {
        ref.read(invalidateUserProvidersProvider)();
        await sl<AuthRepository>().deleteAccount();
        if (context.mounted) context.pushReplacement('/login');
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hesap silinemedi. Lütfen tekrar deneyin.')),
          );
        }
      }
    }
  }

  void _showNoContentDialog(BuildContext context, String bookTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.hourglass_empty_rounded,
          size: 48,
          color: AppColors.primary.withOpacity(0.7),
        ),
        title: Text(
          bookTitle,
          style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Bu kitabın içeriği henüz oluşturulmadı.\nYakında eklenecektir.',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(studentHomeProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(studentHomeProvider.notifier).loadData();
        },
        child: CustomScrollView(
          slivers: [
            // AppBar ve Profil Bilgisi
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      width: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              AppColors.accentDark.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingL,
                        vertical: AppConstants.paddingM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.textOnPrimary
                                    .withOpacity(0.3),
                                child: Text(
                                  homeState.student?.adSoyad.isNotEmpty == true
                                      ? homeState.student!.adSoyad[0]
                                            .toUpperCase()
                                      : 'Ö',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hoş geldin,',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.textOnPrimary
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      homeState.student?.adSoyad ?? 'Öğrenci',
                                      style: AppTextStyles.h5.copyWith(
                                        color: AppColors.textOnPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (homeState.student?.email != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        homeState.student!.email,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textOnPrimary
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: AppColors.textOnPrimary),
                                onSelected: (value) async {
                                  if (value == 'logout') {
                                    ref.read(invalidateUserProvidersProvider)();
                                    await sl<AuthRepository>().logout();
                                    if (context.mounted) context.pushReplacement('/login');
                                  } else if (value == 'delete') {
                                    await _showDeleteAccountDialog(context, ref);
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
                        ],
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
            // İçerik
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hızlı Erişim Butonları
                    AppButton(
                      text: 'Öğretmen Ekle',
                      onPressed: () {
                        context.push('/student/dashboard');
                      },
                      type: AppButtonType.primary,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    AppButton(
                      text: 'Günün Bilgisi',
                      icon: Icons.lightbulb_outline,
                      onPressed: () {
                        showGununBilgisiDialog(context);
                      },
                      type: AppButtonType.outline,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    AppButton(
                      text: 'Rehberlik',
                      icon: Icons.school_outlined,
                      onPressed: () {
                        context.push('/student/rehberlik');
                      },
                      type: AppButtonType.accentOutline,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    // Kitaplar Başlığı
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Kitaplar',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    // Kitap Kartları Grid
                    if (homeState.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (homeState.error != null)
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
                              homeState.error!,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppConstants.paddingM,
                              mainAxisSpacing: AppConstants.paddingM,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: homeState.books.length,
                        itemBuilder: (context, index) {
                          final book = homeState.books[index];
                          return BookCard(
                            book: book,
                            onTap: () {
                              if (book.hasContent) {
                                context.push(
                                  '/student/book-sections',
                                  extra: book,
                                );
                              } else {
                                _showNoContentDialog(context, book.title);
                              }
                            },
                          );
                        },
                      ),
                    const SizedBox(height: AppConstants.paddingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
