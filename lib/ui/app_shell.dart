import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/student_cache.dart';
import '../domain/model/student_profile.dart';
import 'about/about_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'room/empty_room_screen.dart';
import 'student/student_screen.dart';
import 'student/student_view_model.dart';
import 'teacher/teacher_screen.dart';
import 'theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.cache});

  final StudentCache cache;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late bool _showOnboarding;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.cache.seenOnboarding;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
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
        body: _showOnboarding
            ? OnboardingScreen(
                initialProfile: widget.cache.profile,
                onFinished: _finishOnboarding,
              )
            : IndexedStack(
                index: _currentTab,
                children: const [
                  StudentScreen(),
                  TeacherScreen(),
                  EmptyRoomScreen(),
                  AboutScreen(),
                ],
              ),
        bottomNavigationBar: _showOnboarding
            ? null
            : _CapsuleBottomNav(
                currentIndex: _currentTab,
                onTap: (index) => setState(() => _currentTab = index),
              ),
      ),
    );
  }
}

class _CapsuleBottomNav extends StatelessWidget {
  const _CapsuleBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <({IconData icon, IconData activeIcon, String label})>[
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Student'),
    (icon: Icons.badge_outlined, activeIcon: Icons.badge, label: 'Teacher'),
    (
      icon: Icons.door_sliding_outlined,
      activeIcon: Icons.door_sliding,
      label: 'Empty',
    ),
    (icon: Icons.info_outline, activeIcon: Icons.info, label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: line),
            boxShadow: [
              BoxShadow(
                color: ink.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _CapsuleNavItem(
                      icon: _items[i].icon,
                      activeIcon: _items[i].activeIcon,
                      label: _items[i].label,
                      selected: currentIndex == i,
                      onTap: () => onTap(i),
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

class _CapsuleNavItem extends StatelessWidget {
  const _CapsuleNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? peach.withValues(alpha: 0.45) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected ? ink : textMuted,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? ink : textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
