import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SearchRow extends StatefulWidget {
  const SearchRow({
    super.key,
    required this.query,
    required this.onQueryChange,
  });

  final String query;
  final ValueChanged<String> onQueryChange;

  @override
  State<SearchRow> createState() => _SearchRowState();
}

class _SearchRowState extends State<SearchRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(SearchRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22, color: textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onQueryChange,
              style: text.bodyLarge,
              cursorColor: ink,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '68_C',
                hintStyle: text.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
