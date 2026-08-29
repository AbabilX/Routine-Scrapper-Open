import 'package:flutter/material.dart';

import '../../domain/model/student_gender.dart';
import '../../domain/model/student_profile.dart';
import '../student/components/cute_face.dart';
import '../theme/app_colors.dart';
import 'onboarding_page.dart';
import 'onboarding_pages.dart';
import 'onboarding_profile_slide.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onFinished,
    this.initialProfile = StudentProfile.empty,
  });

  final ValueChanged<StudentProfile> onFinished;
  final StudentProfile initialProfile;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  late final TextEditingController _name;
  var _index = 0;
  StudentGender? _gender;

  int get _pageCount => onboardingPages.length + 1;
  bool get _isProfile => _index >= onboardingPages.length;
  bool get _canStart {
    return _name.text.trim().isNotEmpty && _gender != null;
  }

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialProfile.name);
    _name.addListener(() => setState(() {}));
    if (widget.initialProfile.name.isNotEmpty) {
      _gender = widget.initialProfile.gender;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    super.dispose();
  }

  StudentProfile _draft() {
    return StudentProfile(
      name: _name.text.trim().isEmpty
          ? widget.initialProfile.name
          : _name.text.trim(),
      gender: _gender ?? widget.initialProfile.gender,
    );
  }

  void _next() {
    if (_isProfile) {
      if (!_canStart) return;
      widget.onFinished(
        StudentProfile(name: _name.text.trim(), gender: _gender!),
      );
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => widget.onFinished(_draft()),
              child: Text('এড়িয়ে যাও', style: text.labelLarge),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pageCount,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                if (index >= onboardingPages.length) {
                  return OnboardingProfileSlide(
                    nameController: _name,
                    gender: _gender,
                    onGender: (value) => setState(() => _gender = value),
                  );
                }
                return _TourSlide(page: onboardingPages[index]);
              },
            ),
          ),
          const SizedBox(height: 18),
          _Dots(count: _pageCount, index: _index),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _isProfile && !_canStart ? null : _next,
            style: FilledButton.styleFrom(
              backgroundColor: ink,
              disabledBackgroundColor: ink.withValues(alpha: 0.28),
              foregroundColor: onInk,
              disabledForegroundColor: onInk,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              _isProfile ? 'শুরু করো' : 'চলো',
              style: text.titleMedium?.copyWith(color: onInk),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourSlide extends StatelessWidget {
  const _TourSlide({required this.page});

  final OnboardingPage page;

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
              color: page.tint,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (page.showFace)
                    const CyclingCuteFace(size: 72)
                  else
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(page.icon, size: 32, color: ink),
                      ),
                    ),
                  const Spacer(),
                  Text(page.kicker, style: text.labelSmall),
                  const SizedBox(height: 10),
                  Text(page.title, style: text.headlineSmall),
                  const SizedBox(height: 12),
                  Text(page.body, style: text.bodyLarge),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? ink : line,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ],
    );
  }
}
