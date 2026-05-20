import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/goal_type.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';

/// Collects user stats and goal, then runs calculations and saves locally.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  GoalType? _selectedGoal;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fitness goal')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profile = UserProfile(
        uid: user.uid,
        fullName: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        heightCm: double.parse(_heightController.text.trim()),
        weightKg: double.parse(_weightController.text.trim()),
        goal: _selectedGoal!,
        email: user.email,
      );
      await ref.read(userProvider.notifier).saveProfile(profile);
      if (mounted) context.go('/dashboard');
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
        title: Text('Your Profile', style: AppTextStyles.subheading),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Text('Tell us about yourself', style: AppTextStyles.body),
              const SizedBox(height: 24),
              InputField(
                controller: _nameController,
                label: 'Full Name',
                validator: Validators.fullName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              InputField(
                controller: _ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.age,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              InputField(
                controller: _heightController,
                label: 'Height (cm)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.heightCm,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              // TODO: Add imperial (ft/in) unit conversion in a future release.
              Text(
                'Metric units only (cm, kg) in v1',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              InputField(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.weightKg,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              Text('Fitness Goal', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  GoalCard(
                    goal: GoalType.bulk,
                    icon: Icons.trending_up,
                    isSelected: _selectedGoal == GoalType.bulk,
                    onTap: () => setState(() => _selectedGoal = GoalType.bulk),
                  ),
                  GoalCard(
                    goal: GoalType.leanBulk,
                    icon: Icons.fitness_center,
                    isSelected: _selectedGoal == GoalType.leanBulk,
                    onTap: () => setState(() => _selectedGoal = GoalType.leanBulk),
                  ),
                  GoalCard(
                    goal: GoalType.cut,
                    icon: Icons.trending_down,
                    isSelected: _selectedGoal == GoalType.cut,
                    onTap: () => setState(() => _selectedGoal = GoalType.cut),
                  ),
                  GoalCard(
                    goal: GoalType.maintain,
                    icon: Icons.balance,
                    isSelected: _selectedGoal == GoalType.maintain,
                    onTap: () => setState(() => _selectedGoal = GoalType.maintain),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Calculate & Continue',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
