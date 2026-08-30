import 'package:flutter/material.dart';

import '../../../domain/model/student_profile.dart';
import 'cute_face.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({
    super.key,
    this.profile = StudentProfile.empty,
    this.onReplacePdf,
    this.replacing = false,
  });

  final StudentProfile profile;
  final VoidCallback? onReplacePdf;
  final bool replacing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        CyclingCuteFace(size: 52, gender: profile.gender),
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
        if (onReplacePdf != null)
          IconButton(
            tooltip: 'নতুন PDF',
            onPressed: replacing ? null : onReplacePdf,
            icon: replacing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
          ),
      ],
    );
  }
}
