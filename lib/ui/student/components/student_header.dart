import 'package:flutter/material.dart';

import '../../../domain/model/student_profile.dart';
import 'cute_face.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({
    super.key,
    this.profile = StudentProfile.empty,
  });

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        CyclingCuteFace(
          size: 52,
          gender: profile.gender,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text('আজকের ক্লাস খুঁজে নাও', style: text.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}
