import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/model/teacher_info.dart';
import '../theme/app_colors.dart';

class TeacherProfileDialog extends StatelessWidget {
  const TeacherProfileDialog({
    super.key,
    required this.initial,
    this.info,
    this.isLoading = false,
  });

  final String initial;
  final TeacherInfo? info;
  final bool isLoading;

  static Future<void> show({
    required BuildContext context,
    required String initial,
    required Future<TeacherInfo?> Function(String initial) fetcher,
  }) async {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return FutureBuilder<TeacherInfo?>(
          future: fetcher(initial),
          builder: (context, snapshot) {
            final loading =
                snapshot.connectionState == ConnectionState.waiting;
            final teacher = snapshot.data;
            return TeacherProfileDialog(
              initial: initial,
              info: teacher,
              isLoading: loading,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = info?.titleWithInitial ?? initial;
    final hasImage = info != null && info!.imageUrl.isNotEmpty;

    return Dialog(
      backgroundColor: surface,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: line, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Title & Close Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage) ...[
                  ClipOval(
                    child: Image.network(
                      info!.imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackAvatar(),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: line),
                    ),
                    child: const Icon(Icons.close, size: 18, color: textMuted),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(color: line, height: 1),
            const SizedBox(height: 14),

            if (isLoading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ] else if (info == null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, size: 36, color: textMuted),
                    const SizedBox(height: 10),
                    Text(
                      'No detailed profile found for $initial',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (info!.designation.isNotEmpty)
                _buildFieldRow(context, 'Desig', info!.designation),
              if (info!.id.isNotEmpty)
                _buildFieldRow(context, 'ID', info!.id),
              if (info!.cell.isNotEmpty)
                _buildFieldRow(
                  context,
                  'Cell',
                  info!.cell,
                  isHighlight: true,
                  onCopy: () => _copy(context, info!.cell, 'Phone number copied'),
                ),
              if (info!.email.isNotEmpty)
                _buildFieldRow(
                  context,
                  'Email',
                  info!.email,
                  onCopy: () => _copy(context, info!.email, 'Email copied'),
                ),
              if (info!.room.isNotEmpty)
                _buildFieldRow(context, 'Room', info!.room),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: lavender.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: ink, size: 24),
    );
  }

  Widget _buildFieldRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onCopy,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isHighlight ? const Color(0xFF2563EB) : ink,
                  fontSize: 14,
                  fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
