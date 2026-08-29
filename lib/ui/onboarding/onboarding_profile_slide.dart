import 'package:flutter/material.dart';

import '../../domain/model/student_gender.dart';
import '../student/components/cute_face.dart';
import '../theme/app_colors.dart';

class OnboardingProfileSlide extends StatelessWidget {
  const OnboardingProfileSlide({
    super.key,
    required this.nameController,
    required this.gender,
    required this.onGender,
  });

  final TextEditingController nameController;
  final StudentGender? gender;
  final ValueChanged<StudentGender> onGender;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: rose,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CyclingCuteFace(size: 64, gender: gender),
                    const SizedBox(height: 18),
                    Text('তোমাকে চিনি', style: text.labelSmall),
                    const SizedBox(height: 8),
                    Text('নাম আর জেন্ডার', style: text.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'শুধু ফোনে থাকবে — সার্ভারে যায় না।',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _NameField(controller: nameController),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _GenderChip(
                          label: 'মেয়ে',
                          selected: gender == StudentGender.girl,
                          onTap: () => onGender(StudentGender.girl),
                        ),
                        _GenderChip(
                          label: 'ছেলে',
                          selected: gender == StudentGender.boy,
                          onTap: () => onGender(StudentGender.boy),
                        ),
                        _GenderChip(
                          label: 'বলব না',
                          selected: gender == StudentGender.unspecified,
                          onTap: () => onGender(StudentGender.unspecified),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextField(
        controller: controller,
        style: text.bodyLarge,
        cursorColor: ink,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'তোমার নাম',
          hintStyle: text.bodyMedium,
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? mint : surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}
