import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pill primary action — Student-style ink capsule button.
class CutePrimaryButton extends StatelessWidget {
  const CutePrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
    this.icon = Icons.search,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool enabled;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onTap != null;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: active ? ink : ink.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: active ? onTap : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onInk,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: onInk, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: onInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
