import 'package:flutter/material.dart';

import 'cute_face.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        const CuteFace(),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello', style: text.headlineSmall),
            const SizedBox(height: 2),
            Text('আজকের ক্লাস খুঁজে নাও', style: text.labelSmall),
          ],
        ),
      ],
    );
  }
}
