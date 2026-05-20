import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';

/// Email/password registration via Firebase Auth.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final storage = ref.read(storageServiceProvider);
      final credential = await auth.register(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final uid = credential.user!.uid;
      await storage.saveUid(uid);
      if (mounted) context.go('/setup');
    } catch (e) {
      debugPrint('Register error: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Account', style: AppTextStyles.display.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text('Start your transformation journey', style: AppTextStyles.body),
                const SizedBox(height: 32),
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
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _confirmController,
                  label: 'Confirm Password',
                  obscureText: true,
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Register',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Already have an account? Log in',
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
