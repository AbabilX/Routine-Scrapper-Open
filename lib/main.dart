import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/asset_routine_repository.dart';
import 'data/student_prefs.dart';
import 'ui/student/student_screen.dart';
import 'ui/student/student_view_model.dart';
import 'ui/theme/app_colors.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await AssetRoutineRepository.load();
  final prefs = await StudentPrefs.create();
  runApp(RdiuApp(repository: repository, prefs: prefs));
}

class RdiuApp extends StatelessWidget {
  const RdiuApp({
    super.key,
    required this.repository,
    required this.prefs,
  });

  final AssetRoutineRepository repository;
  final StudentPrefs prefs;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentViewModel(repository: repository, prefs: prefs),
      child: MaterialApp(
        title: 'rDIU',
        debugShowCheckedModeBanner: false,
        theme: rdiuTheme(),
        home: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: bg,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(child: StudentScreen()),
          ),
        ),
      ),
    );
  }
}
