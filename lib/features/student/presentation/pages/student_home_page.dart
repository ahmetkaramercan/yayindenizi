import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';
import '../providers/student_home_provider.dart';

class StudentHomePage extends ConsumerWidget {
  const StudentHomePage({super.key});

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
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.textOnPrimary.withOpacity(0.3),
                                child: Text(
                                  homeState.student?.adSoyad.isNotEmpty == true
                                      ? homeState.student!.adSoyad[0].toUpperCase()
                                      : 'Ö',
                                  style: AppTextStyles.h3.copyWith(
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
                                        color: AppColors.textOnPrimary.withOpacity(0.8),
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
                                          color: AppColors.textOnPrimary.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout),
                                color: AppColors.textOnPrimary,
                                onPressed: () {
                                  context.pushReplacement('/login');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Öğretmen Ekle',
                            icon: Icons.person_add,
                            onPressed: () {
                              context.push('/student/dashboard');
                            },
                            type: AppButtonType.primary,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: AppButton(
                            text: 'Analizim',
                            icon: Icons.analytics_outlined,
                            onPressed: () {
                              context.push('/student/analysis');
                            },
                            type: AppButtonType.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    AppButton(
                      text: 'Rehberlik',
                      icon: Icons.school_outlined,
                      onPressed: () {
                        // TODO: Rehberlik sayfasına yönlendir
                        context.showSnackBar('Rehberlik sayfası yakında...');
                      },
                      type: AppButtonType.outline,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    // Kitaplar Başlığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kitaplar',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Tüm kitaplar sayfasına yönlendir
                            context.showSnackBar('Tüm kitaplar yakında...');
                          },
                          child: Text(
                            'Tümünü Gör',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                            ),
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              // Paragraf Koçu için özel yönlendirme
                              if (book.title == 'Paragraf Koçu') {
                                context.push('/student/paragraf-kocu');
                              } else if (book.title == 'Deneme Kitapları') {
                                context.push('/student/deneme-kitaplari');
                              } else if (book.title == 'Konu Kitapları') {
                                context.push('/student/konu-kitaplari');
                              } else {
                                // TODO: Diğer kitaplar için detay sayfasına yönlendir
                                context.showSnackBar('${book.title} açılıyor...');
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

