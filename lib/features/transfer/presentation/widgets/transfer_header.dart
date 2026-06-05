import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A centered header for the send flow: a back chevron, a centered title, and
/// an optional trailing widget (e.g. a cluster pill).
class TransferHeader extends StatelessWidget {
  const TransferHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 14, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: NB.text),
          ),
          Expanded(
            child: Text(title,
                textAlign: TextAlign.center,
                style: NB.font(18, weight: FontWeight.w800)),
          ),
          trailing ?? const SizedBox(width: 40),
        ],
      ),
    );
  }
}
