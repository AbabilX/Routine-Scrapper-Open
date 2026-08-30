import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import 'cute_face.dart';
import 'cute_face_kind.dart';

class UploadRoutineCard extends StatelessWidget {
  const UploadRoutineCard({
    super.key,
    required this.onUpload,
    required this.onUseExisting,
    this.busy = false,
  });

  final VoidCallback onUpload;
  final VoidCallback onUseExisting;
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
            Text('রুটিন চাই', style: text.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'PDF আপলোড অপশনাল। নিজের CSE ক্লাস রুটিন দাও, '
              'অথবা অ্যাপে থাকা bundled ডেটা দিয়েই চালিয়ে যাও। '
              'পরে হেডার থেকে PDF বদলানো যাবে।',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onUpload,
                    style: FilledButton.styleFrom(
                      backgroundColor: ink,
                      disabledBackgroundColor: ink.withValues(alpha: 0.28),
                      foregroundColor: onInk,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
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
                      busy ? 'পার্স হচ্ছে…' : 'PDF আপলোড',
                      style: text.titleMedium?.copyWith(color: onInk),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            onUseExisting();
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink,
                      disabledForegroundColor: ink.withValues(alpha: 0.38),
                      side: const BorderSide(color: ink, width: 1.4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      'আছে এমন ডেটা',
                      style: text.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
