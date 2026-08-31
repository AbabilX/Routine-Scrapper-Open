import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/student_cache.dart';
import '../domain/model/student_profile.dart';
import 'onboarding/onboarding_screen.dart';
import 'room/empty_room_screen.dart';
import 'room/room_schedule_screen.dart';
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
                  RoomScheduleScreen(),
                  EmptyRoomScreen(),
                ],
              ),
        bottomNavigationBar: _showOnboarding
            ? null
            : Container(
                decoration: const BoxDecoration(
                  color: surface,
                  border: Border(
                    top: BorderSide(
                      color: line,
                      width: 1,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentTab,
                  onTap: (index) => setState(() => _currentTab = index),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: ink,
                  unselectedItemColor: textMuted,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: 'Student',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.badge_outlined),
                      activeIcon: Icon(Icons.badge),
                      label: 'Teacher',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search_outlined),
                      activeIcon: Icon(Icons.search),
                      label: 'Room',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.door_sliding_outlined),
                      activeIcon: Icon(Icons.door_sliding),
                      label: 'Empty',
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
