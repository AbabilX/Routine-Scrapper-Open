import 'package:flutter/material.dart';

class OnboardingPage {
  const OnboardingPage({
    required this.kicker,
    required this.title,
    required this.body,
    required this.tint,
    this.icon,
    this.showFace = false,
  });

  final String kicker;
  final String title;
  final String body;
  final Color tint;
  final IconData? icon;
  final bool showFace;
}
