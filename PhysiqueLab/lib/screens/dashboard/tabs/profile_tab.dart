import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/goal_type.dart';
import '../../../models/user_profile.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../utils/validators.dart';
import '../../../widgets/goal_card.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/section_header.dart';

/// Profile tab — view/edit stats, change goal, logout.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProvider);
    final uid = profile?.uid ?? await ref.read(storageServiceProvider).getUid();
    await ref.read(authServiceProvider).signOut();
    if (uid != null) {
      await ref.read(storageServiceProvider).clearAll(uid);
    }
    await ref.read(userProvider.notifier).clear();
    if (context.mounted) context.go('/login');
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, UserProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditProfileSheet(profile: profile),
    );
  }

  void _showGoalSheet(BuildContext context, WidgetRef ref, UserProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _GoalChangeSheet(currentGoal: profile.goal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProvider);
    final email = FirebaseAuth.instance.currentUser?.email ?? profile?.email ?? '';

    if (profile == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text('Profile', style: AppTextStyles.heading),
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
            style: AppTextStyles.heading.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(profile.fullName, style: AppTextStyles.subheading),
        Text(email, style: AppTextStyles.body),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Current Stats'),
        _InfoRow(label: 'Age', value: '${profile.age} years'),
        _InfoRow(label: 'Height', value: '${profile.heightCm} cm'),
        _InfoRow(label: 'Weight', value: '${profile.weightKg} kg'),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showGoalSheet(context, ref, profile),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Goal', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(profile.goal.label, style: AppTextStyles.subheading),
                  ],
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Edit Profile',
          onPressed: () => _showEditProfileSheet(context, ref, profile),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            await ref.read(userProvider.notifier).saveProfile(profile);
            if (context.mounted) {
              showSuccessSnackBar(context, 'Targets recalculated');
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
          child: Text('RECALCULATE', style: AppTextStyles.button),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _logout(context, ref),
          child: Text(
            'Log Out',
            style: AppTextStyles.button.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.subheading.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _ageController = TextEditingController(text: '${widget.profile.age}');
    _heightController = TextEditingController(text: '${widget.profile.heightCm}');
    _weightController = TextEditingController(text: '${widget.profile.weightKg}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.profile.copyWith(
      fullName: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      heightCm: double.parse(_heightController.text.trim()),
      weightKg: double.parse(_weightController.text.trim()),
    );
    await ref.read(userProvider.notifier).updateProfile(updated);
    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackBar(context, 'Profile updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: AppTextStyles.heading.copyWith(fontSize: 22)),
              const SizedBox(height: 20),
              InputField(controller: _nameController, label: 'Full Name', validator: Validators.fullName),
              const SizedBox(height: 12),
              InputField(
                controller: _ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.age,
              ),
              const SizedBox(height: 12),
              InputField(
                controller: _heightController,
                label: 'Height (cm)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.heightCm,
              ),
              const SizedBox(height: 12),
              InputField(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.weightKg,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Save', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalChangeSheet extends ConsumerStatefulWidget {
  const _GoalChangeSheet({required this.currentGoal});

  final GoalType currentGoal;

  @override
  ConsumerState<_GoalChangeSheet> createState() => _GoalChangeSheetState();
}

class _GoalChangeSheetState extends ConsumerState<_GoalChangeSheet> {
  late GoalType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentGoal;
  }

  Future<void> _confirm() async {
    final profile = ref.read(userProvider);
    if (profile == null) return;
    await ref.read(userProvider.notifier).updateProfile(profile.copyWith(goal: _selected));
    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackBar(context, 'Goal updated — targets refreshed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Change Goal', style: AppTextStyles.heading.copyWith(fontSize: 22)),
          const SizedBox(height: 20),
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
                isSelected: _selected == GoalType.bulk,
                onTap: () => setState(() => _selected = GoalType.bulk),
              ),
              GoalCard(
                goal: GoalType.leanBulk,
                icon: Icons.fitness_center,
                isSelected: _selected == GoalType.leanBulk,
                onTap: () => setState(() => _selected = GoalType.leanBulk),
              ),
              GoalCard(
                goal: GoalType.cut,
                icon: Icons.trending_down,
                isSelected: _selected == GoalType.cut,
                onTap: () => setState(() => _selected = GoalType.cut),
              ),
              GoalCard(
                goal: GoalType.maintain,
                icon: Icons.balance,
                isSelected: _selected == GoalType.maintain,
                onTap: () => setState(() => _selected = GoalType.maintain),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Confirm', onPressed: _confirm),
        ],
      ),
    );
  }
}
