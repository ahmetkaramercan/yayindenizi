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
import '../providers/student_register_provider.dart';

class StudentRegisterPage extends ConsumerStatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  ConsumerState<StudentRegisterPage> createState() =>
      _StudentRegisterPageState();
}

class _StudentRegisterPageState extends ConsumerState<StudentRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _adSoyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _adSoyadController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      ref.read(studentRegisterProvider.notifier).register(
            adSoyad: _adSoyadController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            cityId: null,
            districtId: null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(studentRegisterProvider);

    // Hata mesajını göster
    if (registerState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showSnackBar(
          registerState.error!,
          backgroundColor: AppColors.error,
        );
        ref.read(studentRegisterProvider.notifier).reset();
      });
    }

    // Başarılı kayıt durumunda yönlendirme
    if (registerState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(studentRegisterProvider.notifier).reset();
        context.pop();
        context.showSnackBar(
          'Kayıt başarılı! Giriş yapabilirsiniz.',
          backgroundColor: AppColors.success,
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Öğrenci Kayıt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Yeni Hesap Oluştur',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Öğrenci olarak kayıt olun',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Ad Soyad Field
                AppTextField(
                  label: 'Ad Soyad',
                  hint: 'Adınız ve soyadınız',
                  controller: _adSoyadController,
                  keyboardType: TextInputType.name,
                  validator: (value) => Validators.name(value, fieldName: 'Ad Soyad'),
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: AppConstants.paddingM),
                // Email Field
                AppTextField(
                  label: 'Email *',
                  hint: 'ornek@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: AppConstants.paddingM),
                // Password Field
                AppTextField(
                  label: 'Şifre *',
                  hint: 'En az 6 karakter',
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
                const SizedBox(height: AppConstants.paddingM),
                // Password Confirm Field
                AppTextField(
                  label: 'Şifre Tekrar *',
                  hint: 'Şifrenizi tekrar girin',
                  controller: _passwordConfirmController,
                  obscureText: _obscurePasswordConfirm,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePasswordConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePasswordConfirm = !_obscurePasswordConfirm;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.paddingL),
                // Register Button
                AppButton(
                  text: 'Kayıt Ol',
                  onPressed: registerState.isLoading ? null : _handleRegister,
                  isLoading: registerState.isLoading,
                  isFullWidth: true,
                  type: AppButtonType.primary,
                ),
                const SizedBox(height: AppConstants.paddingM),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten hesabınız var mı? ',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Giriş Yap',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
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
      ),
    );
  }
}

