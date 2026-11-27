import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/nimbus_widgets.dart';
import '../xend_error_text.dart';
import 'wallet_ready_screen.dart';

/// "I already have a wallet": enter a 12/24-word phrase and restore it.
class ImportWalletFlow extends ConsumerStatefulWidget {
  const ImportWalletFlow({super.key, required this.onExit, required this.onDone});

  final VoidCallback onExit;
  final VoidCallback onDone;

  @override
  ConsumerState<ImportWalletFlow> createState() => _ImportWalletFlowState();
}

class _ImportWalletFlowState extends ConsumerState<ImportWalletFlow> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(walletSessionProvider).activeAccount;
    final Widget child = _ready && account != null
        ? WalletReadyScreen(
            key: const ValueKey('ready'),
            account: account,
            onOpen: widget.onDone,
          )
        : _EnterPhrase(
            key: const ValueKey('enter'),
            onBack: widget.onExit,
            onImported: () => setState(() => _ready = true),
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (c, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.08, 0), end: Offset.zero)
              .animate(anim),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _EnterPhrase extends ConsumerStatefulWidget {
  const _EnterPhrase({
    super.key,
    required this.onBack,
    required this.onImported,
  });

  final VoidCallback onBack;
  final VoidCallback onImported;

  @override
  ConsumerState<_EnterPhrase> createState() => _EnterPhraseState();
}

class _EnterPhraseState extends ConsumerState<_EnterPhrase> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _words {
    final t = _controller.text.trim().toLowerCase();
    return t.isEmpty ? const [] : t.split(RegExp(r'\s+'));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(walletSessionProvider.notifier)
          .importWallet(_words.join(' '));
      if (mounted) widget.onImported();
    } catch (e) {
      debugPrint('importWallet failed: ${e.runtimeType}');
      if (mounted) setState(() => _error = xendErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _words.length;
    final lengthOk = count == 12 || count == 24;
    return Scaffold(
      backgroundColor: NB.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NbHeader(onBack: _busy ? null : widget.onBack),
              Text('Import a wallet',
                  style: NB.font(27, weight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 10),
              Text(
                'Enter your 12 or 24-word recovery phrase. Your key is rebuilt '
                'on this device and the phrase never leaves your phone.',
                style: NB.font(14.5, color: NB.text2, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: NB.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _error != null ? NB.red : NB.border),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  enabled: !_busy,
                  onChanged: (_) => setState(() => _error = null),
                  maxLines: 4,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  style: NB.font(15, color: NB.text, height: 1.6),
                  decoration: InputDecoration.collapsed(
                    hintText: 'recovery phrase…',
                    hintStyle: NB.font(15, color: NB.text3),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _error ?? 'Separate words with spaces',
                      style: NB.font(12,
                          color: _error != null ? NB.red : NB.text3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$count word${count == 1 ? '' : 's'}',
                      style: NB.font(12,
                          weight: FontWeight.w700,
                          color: lengthOk ? NB.green : NB.text2)),
                ],
              ),
              const Spacer(),
              NbButton(
                label: _busy ? 'Importing…' : 'Import wallet',
                enabled: lengthOk && !_busy,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
