import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/model/teacher_info.dart';
import '../theme/app_colors.dart';

/// Teacher profile as a modal bottom sheet (not a centered dialog).
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
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return FutureBuilder<TeacherInfo?>(
          future: fetcher(initial),
          builder: (context, snapshot) {
            final loading =
                snapshot.connectionState == ConnectionState.waiting;
            return TeacherProfileDialog(
              initial: initial,
              info: snapshot.data,
              isLoading: loading,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final title = info?.titleWithInitial ?? initial;
    final hasImage = info != null && info!.imageUrl.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage)
                      ClipOval(
                        child: Image.network(
                          info!.imageUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackAvatar(),
                        ),
                      )
                    else
                      _fallbackAvatar(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: text.titleLarge,
                          ),
                          if (info != null &&
                              info!.designation.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              info!.designation,
                              style: text.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Material(
                      color: bg,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close, size: 18, color: textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
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
                  )
                else if (info == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No detailed profile found for $initial',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium,
                    ),
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: lavender.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        children: [
                          if (info!.id.isNotEmpty)
                            _FieldRow(label: 'ID', value: info!.id),
                          if (info!.cell.isNotEmpty)
                            _FieldRow(
                              label: 'Cell',
                              value: info!.cell,
                              highlight: true,
                              actionIcon: Icons.phone_rounded,
                              onTap: () => _launchPhone(context, info!.cell),
                              onLongPress: () => _copy(
                                context,
                                info!.cell,
                                'Phone number copied',
                              ),
                            ),
                          if (info!.email.isNotEmpty)
                            _FieldRow(
                              label: 'Email',
                              value: info!.email,
                              highlight: true,
                              actionIcon: Icons.mail_outline_rounded,
                              onTap: () => _launchEmail(context, info!.email),
                              onLongPress: () => _copy(
                                context,
                                info!.email,
                                'Email copied',
                              ),
                            ),
                          if (info!.room.isNotEmpty)
                            _FieldRow(label: 'Room', value: info!.room),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: lavender,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: ink, size: 26),
    );
  }

  static String _digitsForTel(String raw) {
    return raw.replaceAll(RegExp(r'[^\d+]'), '');
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final cleaned = _digitsForTel(phone);
    if (cleaned.isEmpty) return;
    await _launchUri(
      context,
      Uri.parse('tel:$cleaned'),
      fallbackText: phone,
      fallbackMessage: 'Phone number copied',
    );
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    await _launchUri(
      context,
      Uri(
        scheme: 'mailto',
        path: trimmed,
      ),
      fallbackText: trimmed,
      fallbackMessage: 'Email copied',
    );
  }

  Future<void> _launchUri(
    BuildContext context,
    Uri uri, {
    required String fallbackText,
    required String fallbackMessage,
  }) async {
    HapticFeedback.selectionClick();
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      await _copy(context, fallbackText, fallbackMessage);
    }
  }

  Future<void> _copy(
    BuildContext context,
    String text,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.actionIcon,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final String value;
  final bool highlight;
  final IconData? actionIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final interactive = onTap != null;
    final valueStyle = text.bodyMedium?.copyWith(
      color: highlight ? const Color(0xFF2563EB) : ink,
      fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
      decoration: interactive ? TextDecoration.underline : null,
      decorationColor: highlight ? const Color(0xFF2563EB) : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: text.labelSmall),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: valueStyle,
              ),
            ),
          ),
          if (actionIcon != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onTap,
              child: Icon(
                actionIcon,
                size: 16,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
