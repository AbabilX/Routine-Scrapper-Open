import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api/live_routine_repository.dart';
import 'data/api/routine_api_cache.dart';
import 'data/api/routine_api_client.dart';
import 'data/class_reminder_scheduler.dart';
import 'data/student_cache.dart';
import 'ui/app_shell.dart';
import 'ui/room/room_view_model.dart';
import 'ui/student/student_view_model.dart';
import 'ui/teacher/teacher_view_model.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cache = await StudentCache.load();
  final scheduler = await ClassReminderScheduler.create();
  final live = LiveRoutineRepository(
    client: RoutineApiClient(),
    cache: RoutineApiCache(),
  );
  runApp(
    DIUApp(
      live: live,
      cache: cache,
      scheduler: scheduler,
    ),
  );
}

class DIUApp extends StatelessWidget {
  const DIUApp({
    super.key,
    required this.live,
    required this.cache,
    required this.scheduler,
  });

  final LiveRoutineRepository live;
  final StudentCache cache;
  final ClassReminderScheduler scheduler;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StudentViewModel(
            live: live,
            cache: cache,
            scheduler: scheduler,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TeacherViewModel(live: live),
        ),
        ChangeNotifierProvider(
          create: (_) => RoomViewModel(live: live),
        ),
      ],
      child: MaterialApp(
        title: 'DIU Routine',
        debugShowCheckedModeBanner: false,
        theme: DIUTheme(),
        home: AppShell(cache: cache),
      ),
    );
  }
}
