import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';

/// Email/password login with password reset support.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final storage = ref.read(storageServiceProvider);
      final credential = await auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final uid = credential.user!.uid;
      await storage.saveUid(uid);
      await ref.read(userProvider.notifier).loadProfile(uid);
      final profile = ref.read(userProvider);
      if (!mounted) return;
      if (profile != null) {
        context.go('/dashboard');
      } else {
        context.go('/setup');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        showErrorSnackBar(
          context,
          ref.read(authServiceProvider).mapException(e),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showErrorSnackBar(context, 'Enter your email above first');
      return;
    }
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (mounted) {
        showSuccessSnackBar(context, 'Password reset email sent');
      }
    } catch (e) {
      debugPrint('Reset error: $e');
      if (mounted) {
        showErrorSnackBar(
          context,
          ref.read(authServiceProvider).mapException(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('Welcome Back', style: AppTextStyles.display.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text('Log in to continue your plan', style: AppTextStyles.body),
                const SizedBox(height: 40),
                InputField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Log In',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      'New here? Create an account',
                      style: AppTextStyles.body.copyWith(color: AppColors.primaryLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
