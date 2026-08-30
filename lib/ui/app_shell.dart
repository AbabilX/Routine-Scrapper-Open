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
  }

  Future<void> _finishOnboarding(StudentProfile profile) async {
    await context.read<StudentViewModel>().completeOnboarding(profile);
    if (!mounted) return;
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTab = _currentTab == 3;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkTab ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkTab ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkTab ? const Color(0xFF13141F) : bg,
        systemNavigationBarIconBrightness: isDarkTab
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDarkTab ? const Color(0xFF13141F) : bg,
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
                decoration: BoxDecoration(
                  color: isDarkTab ? const Color(0xFF161622) : surface,
                  border: Border(
                    top: BorderSide(
                      color: isDarkTab ? const Color(0xFF262738) : line,
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
                  selectedItemColor: isDarkTab ? const Color(0xFF8B5CF6) : ink,
                  unselectedItemColor: isDarkTab ? Colors.white38 : textMuted,
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
