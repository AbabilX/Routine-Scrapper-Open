import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SelectOptionModal extends StatelessWidget {
  const SelectOptionModal({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static Future<int?> show({
    required BuildContext context,
    required String title,
    required List<String> options,
    required int selectedIndex,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SelectOptionModal(
          title: title,
          options: options,
          selectedIndex: selectedIndex,
          onSelected: (index) => Navigator.of(context).pop(index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: line, height: 1),
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  final text = options[index];

                  return InkWell(
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                color: isSelected ? ink : textMuted,
                                fontSize: 18,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? ink : line,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isSelected
                                ? Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ink,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
