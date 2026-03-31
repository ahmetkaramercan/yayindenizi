import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/login_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(loginProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Hata mesajını göster
    if (loginState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showSnackBar(
          loginState.error!,
          backgroundColor: AppColors.error,
        );
        ref.read(loginProvider.notifier).reset();
      });
    }

    // Başarılı giriş durumunda role göre yönlendirme
    if (loginState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final role = loginState.userRole;
        ref.read(loginProvider.notifier).reset();
        if (role == 'TEACHER') {
          context.pushReplacement('/teacher/dashboard');
        } else {
          context.pushReplacement('/student/home');
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image - Full width, no top gap
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.55,
                child: Image.asset(
                  'assets/images/logo/login_foto.jpeg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Form content
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingL,
                right: AppConstants.paddingL,
                bottom: AppConstants.paddingL,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hesabınıza giriş yapın',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Email Field
                    AppTextField(
                      label: 'Email',
                      hint: 'ornek@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    // Password Field
                    AppTextField(
                      label: 'Şifre',
                      hint: 'Şifrenizi girin',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: Validators.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    // Login Button
                    AppButton(
                      text: 'Giriş Yap',
                      onPressed: loginState.isLoading ? null : _handleLogin,
                      isLoading: loginState.isLoading,
                      isFullWidth: true,
                      type: AppButtonType.primary,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    // Register Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Hesabınız yok mu? ',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register/student'),
                          child: Text(
                            'Öğrenci Kayıt',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Öğretmen misiniz? ',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register/teacher'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                          ),
                          child: Text(
                            'Öğretmen Kayıt',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }
}
