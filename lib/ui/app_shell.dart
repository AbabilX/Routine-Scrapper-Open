import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/student_cache.dart';
import '../domain/model/student_profile.dart';
import 'onboarding/onboarding_screen.dart';
import 'student/student_screen.dart';
import 'student/student_view_model.dart';
import 'theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.cache});

  final StudentCache cache;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.cache.seenOnboarding;
  }

  Future<void> _finishOnboarding(StudentProfile profile) async {
    await context.read<StudentViewModel>().completeOnboarding(profile);
    if (!mounted) return;
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: SizedBox.expand(
              key: ValueKey(_showOnboarding ? 'onboarding' : 'student'),
              child: _showOnboarding
                  ? OnboardingScreen(
                      initialProfile: widget.cache.profile,
                      onFinished: _finishOnboarding,
                    )
                  : const StudentScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
