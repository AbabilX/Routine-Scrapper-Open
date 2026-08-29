import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/asset_routine_repository.dart';
import 'data/class_reminder_scheduler.dart';
import 'data/local_routine_store.dart';
import 'data/student_cache.dart';
import 'ui/app_shell.dart';
import 'ui/student/student_view_model.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await AssetRoutineRepository.load(LocalRoutineStore());
  final cache = await StudentCache.load();
  final scheduler = await ClassReminderScheduler.create();
  runApp(
    DIUApp(
      repository: repository,
      cache: cache,
      scheduler: scheduler,
    ),
  );
}

class DIUApp extends StatelessWidget {
  const DIUApp({
    super.key,
    required this.repository,
    required this.cache,
    required this.scheduler,
  });

  final AssetRoutineRepository repository;
  final StudentCache cache;
  final ClassReminderScheduler scheduler;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentViewModel(
        repository: repository,
        cache: cache,
        scheduler: scheduler,
      ),
      child: MaterialApp(
        title: 'DIU',
        debugShowCheckedModeBanner: false,
        theme: DIUTheme(),
        home: AppShell(cache: cache),
      ),
    );
  }
}
