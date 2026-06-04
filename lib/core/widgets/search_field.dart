import 'package:flutter/material.dart';

import '../theme/nimbus_theme.dart';

/// A reusable rounded search field (surface2, leading magnifier, clear button).
/// The parent owns the [controller] and the filtered results it drives.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
    this.dense = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  /// A more compact height/typography (used on denser screens like Discovery).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final fontSize = dense ? 14.0 : 15.5;
    return Container(
      height: dense ? 42 : 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: NB.surface2,
        borderRadius: BorderRadius.circular(dense ? 13 : 14),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: dense ? 18 : 20, color: NB.text3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: NB.orange,
              style: NB.font(fontSize, color: NB.text),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: NB.font(fontSize, color: NB.text3),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.close, size: 18, color: NB.text3),
              ),
            ),
        ],
      ),
    );
  }
}
