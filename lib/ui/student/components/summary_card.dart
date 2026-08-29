import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/model/student_summary.dart';
import '../../theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.summary,
    required this.onDownload,
  });

  final StudentSummary summary;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final title = summary.section == 'All'
        ? summary.batch
        : '${summary.batch}  ${summary.section}';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: peach,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    '${summary.totalCourses} courses  ·  ${summary.classesPerWeek} classes',
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
            Material(
              color: ink,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onDownload();
                },
                child: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(Icons.download_outlined, color: onInk, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
