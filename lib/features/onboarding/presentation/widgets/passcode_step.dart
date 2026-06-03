import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import 'nimbus_widgets.dart';
import 'passcode_pad.dart';

/// A full-screen passcode entry step (set / confirm / unlock) with a header.
/// Shared by the create and import flows and the unlock screen.
class PasscodeStep extends StatelessWidget {
  const PasscodeStep({
    super.key,
    required this.padKey,
    required this.title,
    required this.subtitle,
    required this.onCompleted,
    this.onBack,
    this.errorText,
    this.busy = false,
    this.footer,
  });

  final GlobalKey<PasscodePadState> padKey;
  final String title;
  final String subtitle;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onBack;
  final String? errorText;
  final bool busy;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            children: [
              if (onBack != null)
                NbHeader(onBack: onBack)
              else
                const SizedBox(height: 56),
              const Spacer(),
              PasscodePad(
                key: padKey,
                title: title,
                subtitle: subtitle,
                errorText: errorText,
                busy: busy,
                onCompleted: onCompleted,
              ),
              const Spacer(),
              if (footer != null) footer!,
            ],
          ),
        ),
      ),
    );
  }
}
