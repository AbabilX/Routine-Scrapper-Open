import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'cute_face.dart';
import 'cute_face_kind.dart';

class UploadRoutineCard extends StatelessWidget {
  const UploadRoutineCard({
    super.key,
    required this.onUpload,
    this.busy = false,
  });

  final VoidCallback onUpload;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: peach,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CuteFace(size: 56, kind: CuteFaceKind.fox),
            const SizedBox(height: 16),
            Text('নিজের রুটিন চাই', style: text.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'DIU CSE ক্লাস রুটিন PDF আপলোড করো — পার্স হয়ে শুধু তোমার রুটিন এখানে থাকবে। '
              'আগেরটা পরের আপলোড পর্যন্ত সেভ থাকবে।',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: busy ? null : onUpload,
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                disabledBackgroundColor: ink.withValues(alpha: 0.28),
                foregroundColor: onInk,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: onInk,
                      ),
                    )
                  : const Icon(Icons.upload_file_outlined),
              label: Text(
                busy ? 'পার্স হচ্ছে…' : 'PDF আপলোড করো',
                style: text.titleMedium?.copyWith(color: onInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
