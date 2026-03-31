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
import '../providers/teacher_register_provider.dart';

class TeacherRegisterPage extends ConsumerStatefulWidget {
  const TeacherRegisterPage({super.key});

  @override
  ConsumerState<TeacherRegisterPage> createState() =>
      _TeacherRegisterPageState();
}

class _TeacherRegisterPageState extends ConsumerState<TeacherRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _adSoyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _okulController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _adSoyadController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _okulController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      ref.read(teacherRegisterProvider.notifier).register(
            adSoyad: _adSoyadController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            cityId: null,
            districtId: null,
            okul: _okulController.text.trim().isEmpty
                ? null
                : _okulController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(teacherRegisterProvider);

    // Hata mesajını göster
    if (registerState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showSnackBar(
          registerState.error!,
          backgroundColor: AppColors.error,
        );
        ref.read(teacherRegisterProvider.notifier).reset();
      });
    }

    // Başarılı kayıt → direkt dashboard'a yönlendir
    if (registerState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(teacherRegisterProvider.notifier).reset();
        context.pushReplacement('/teacher/dashboard');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Öğretmen Kayıt'),
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
                  'Öğretmen olarak kayıt olun',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Ad Soyad',
                  hint: 'Adınız ve soyadınız',
                  controller: _adSoyadController,
                  keyboardType: TextInputType.name,
                  validator: (value) => Validators.name(value, fieldName: 'Ad Soyad'),
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: AppConstants.paddingM),
                AppTextField(
                  label: 'Email *',
                  hint: 'ornek@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: AppConstants.paddingM),
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
                const SizedBox(height: AppConstants.paddingM),
                AppTextField(
                  label: 'Okul',
                  hint: 'Okul adı',
                  controller: _okulController,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
                const SizedBox(height: AppConstants.paddingL),
                AppButton(
                  text: 'Kayıt Ol',
                  onPressed: registerState.isLoading ? null : _handleRegister,
                  isLoading: registerState.isLoading,
                  isFullWidth: true,
                  type: AppButtonType.primary,
                ),
                const SizedBox(height: AppConstants.paddingM),
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
