import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xend/xend.dart';

import '../../domain/entities/blockchain_account.dart';
import '../../domain/entities/chain_family.dart';
import '../../domain/entities/network.dart';
import '../../domain/entities/wallet_account.dart';

/// Lifecycle status of the on-device wallet.
enum VaultStatus {
  /// Not yet determined (initial / loading).
  unknown,

  /// No wallet on this device and none to recover.
  noWallet,

  /// Kept for routing compatibility. Xend wallets are never "locked": each signature
  /// is gated by Face ID instead of a session passcode.
  locked,

  /// A wallet is loaded.
  unlocked,
}

/// Immutable snapshot of the wallet session for the UI to render.
class WalletSessionState {
  const WalletSessionState({
    this.status = VaultStatus.unknown,
    this.wallet,
    this.accounts = const [],
    this.activeAccountIndex = 0,
    this.activeNetwork = Network.solana,
    this.isBusy = false,
    this.error,
  });

  final VaultStatus status;

  /// The Xend wallet. Keys live in the Secure Enclave; this holds only the address.
  final XendWallet? wallet;
  final List<WalletAccount> accounts;
  final int activeAccountIndex;
  final Network activeNetwork;
  final bool isBusy;
  final String? error;

  WalletAccount? get activeAccount => accounts.isEmpty ? null : accounts.first;

  bool get hasAccounts => accounts.isNotEmpty;

  WalletSessionState copyWith({
    VaultStatus? status,
    XendWallet? wallet,
    List<WalletAccount>? accounts,
    int? activeAccountIndex,
    Network? activeNetwork,
    bool? isBusy,
    Object? error = _sentinel,
  }) {
    return WalletSessionState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      accounts: accounts ?? this.accounts,
      activeAccountIndex: activeAccountIndex ?? this.activeAccountIndex,
      activeNetwork: activeNetwork ?? this.activeNetwork,
      isBusy: isBusy ?? this.isBusy,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();
}

/// Drives the wallet session on top of the Xend SDK: load or silently recover on
/// launch, create, import from a phrase, reveal the phrase, delete.
final walletSessionProvider =
    StateNotifierProvider<WalletSessionNotifier, WalletSessionState>((ref) {
  return WalletSessionNotifier()..refresh();
});

/// The loaded wallet, or null before onboarding. Use for balance, send, history.
final xendWalletProvider = Provider<XendWallet?>(
  (ref) => ref.watch(walletSessionProvider.select((s) => s.wallet)),
);

class WalletSessionNotifier extends StateNotifier<WalletSessionState> {
  WalletSessionNotifier() : super(const WalletSessionState());

  static const _labelKey = 'nimbus.account_label.v1';

  /// Load the wallet on this device, or recover it from the iCloud backup.
  Future<void> refresh() async {
    try {
      final wallet = await XendWallet.load();
      state = wallet == null
          ? const WalletSessionState(status: VaultStatus.noWallet)
          : await _loaded(wallet);
    } catch (e, st) {
      // Never strand the UI on the loader.
      debugPrint('WalletSession.refresh failed: $e\n$st');
      state = state.copyWith(status: VaultStatus.noWallet, error: _humanize(e));
    }
  }

  /// Create a wallet silently. No phrase is shown; it can be exported later.
  Future<void> createWallet({String label = 'Account 1'}) => _run(() async {
        final wallet = await XendWallet.create(label: label);
        await _saveLabel(label);
        return _loaded(wallet);
      });

  /// Restore from a 12/24-word recovery phrase.
  Future<void> importWallet(String mnemonic) => _run(() async {
        final wallet = await XendWallet.restore(mnemonic.trim());
        return _loaded(wallet);
      });

  /// The recovery phrase, behind Face ID.
  Future<String> revealRecoveryPhrase() {
    final wallet = state.wallet;
    if (wallet == null) throw StateError('No wallet');
    return wallet.revealRecoveryPhrase();
  }

  Future<void> renameAccount(int index, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    await _saveLabel(trimmed);
    state = state.copyWith(
      accounts: [for (final a in state.accounts) a.copyWith(label: trimmed)],
    );
  }

  void selectNetwork(Network network) =>
      state = state.copyWith(activeNetwork: network);

  /// Remove the wallet from this device. With [wipeBackup] the iCloud backup goes
  /// too, and the wallet is gone unless the user saved the phrase.
  Future<void> deleteWallet({bool wipeBackup = false}) => _run(() async {
        await state.wallet?.delete(wipeBackup: wipeBackup);
        return const WalletSessionState(status: VaultStatus.noWallet);
      });

  Future<WalletSessionState> _loaded(XendWallet wallet) async {
    final label = await _readLabel() ?? 'Account 1';
    final account = WalletAccount(
      index: 0,
      label: label,
      accountsByFamily: {
        ChainFamily.solana: BlockchainAccount(
          family: ChainFamily.solana,
          address: wallet.address,
          publicKeyHex: '',
          derivationPath: "m/44'/501'/0'/0'",
          accountIndex: 0,
        ),
      },
    );
    return state.copyWith(
      status: VaultStatus.unlocked,
      wallet: wallet,
      accounts: [account],
      activeAccountIndex: 0,
      activeNetwork: Network.solana,
      error: null,
    );
  }

  Future<String?> _readLabel() async {
    try {
      return (await SharedPreferences.getInstance()).getString(_labelKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveLabel(String label) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_labelKey, label);
    } catch (_) {}
  }

  /// Run an async action with busy/error bookkeeping. Rethrows so callers can show
  /// inline feedback.
  Future<void> _run(Future<WalletSessionState> Function() action) async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      final next = await action();
      state = next.copyWith(isBusy: false);
    } catch (e) {
      state = state.copyWith(isBusy: false, error: _humanize(e));
      rethrow;
    }
  }

  String _humanize(Object e) {
    if (e is XendError) return e.message;
    final s = e.toString();
    final i = s.indexOf(': ');
    return i >= 0 ? s.substring(i + 2) : s;
  }
}
