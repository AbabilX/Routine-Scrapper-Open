import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_type.dart';

ThemeData DIUTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'sans-serif',
    colorScheme: const ColorScheme.light(
      primary: ink,
      onPrimary: onInk,
      surface: surface,
      onSurface: ink,
      secondary: mint,
      tertiary: lavender,
      outline: line,
    ),
    scaffoldBackgroundColor: bg,
    textTheme: DIUTextTheme,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
