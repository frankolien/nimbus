import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/storage/seed_vault.dart';
import '../../data/wallet_vault.dart';
import '../../domain/entities/network.dart';
import '../../domain/entities/wallet_account.dart';

/// Lifecycle status of the on-device wallet.
enum VaultStatus {
  /// Not yet determined (initial / loading).
  unknown,

  /// No wallet has been created or imported on this device.
  noWallet,

  /// A wallet exists but the session is locked (phrase not in memory).
  locked,

  /// A wallet exists and is unlocked for this session.
  unlocked,
}

/// Immutable snapshot of the wallet session for the UI to render.
class WalletSessionState {
  const WalletSessionState({
    this.status = VaultStatus.unknown,
    this.accounts = const [],
    this.activeAccountIndex = 0,
    this.activeNetwork = Network.solana,
    this.isBusy = false,
    this.error,
  });

  final VaultStatus status;
  final List<WalletAccount> accounts;
  final int activeAccountIndex;
  final Network activeNetwork;
  final bool isBusy;
  final String? error;

  WalletAccount? get activeAccount => accounts.firstWhere(
        (a) => a.index == activeAccountIndex,
        orElse: () => accounts.isNotEmpty
            ? accounts.first
            : throw StateError('no accounts'),
      );

  bool get hasAccounts => accounts.isNotEmpty;

  WalletSessionState copyWith({
    VaultStatus? status,
    List<WalletAccount>? accounts,
    int? activeAccountIndex,
    Network? activeNetwork,
    bool? isBusy,
    Object? error = _sentinel,
  }) {
    return WalletSessionState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      activeAccountIndex: activeAccountIndex ?? this.activeAccountIndex,
      activeNetwork: activeNetwork ?? this.activeNetwork,
      isBusy: isBusy ?? this.isBusy,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();
}

/// Provides the [WalletVault]. Override in tests with a fake-backed vault.
final walletVaultProvider = Provider<WalletVault>((ref) {
  return WalletVault(vault: SecureSeedVault());
});

/// Drives the wallet session: determines status, runs create/import/unlock,
/// and exposes the current accounts/active selection to the UI.
final walletSessionProvider =
    StateNotifierProvider<WalletSessionNotifier, WalletSessionState>((ref) {
  return WalletSessionNotifier(ref.watch(walletVaultProvider))..refresh();
});

class WalletSessionNotifier extends StateNotifier<WalletSessionState> {
  WalletSessionNotifier(this._vault) : super(const WalletSessionState());

  final WalletVault _vault;

  /// Determine whether a wallet exists; UI uses this to route to onboarding,
  /// the unlock screen, or the home screen.
  Future<void> refresh() async {
    try {
      final exists = await _vault.hasWallet();
      state = state.copyWith(
        status: exists
            ? (_vault.isUnlocked ? VaultStatus.unlocked : VaultStatus.locked)
            : VaultStatus.noWallet,
      );
    } catch (e, st) {
      // Never strand the UI on the loader. Treat an unreadable vault as "no
      // wallet" so onboarding can proceed, and surface the failure loudly.
      debugPrint('WalletSession.refresh failed: $e\n$st');
      state = state.copyWith(status: VaultStatus.noWallet);
    }
  }

  Future<void> createWallet({
    required String mnemonic,
    required String passcode,
  }) =>
      _run(() async {
        final accounts =
            await _vault.createWallet(mnemonic: mnemonic, passcode: passcode);
        return _unlockedState(accounts);
      });

  Future<void> importWallet({
    required String mnemonic,
    required String passcode,
  }) =>
      _run(() async {
        final accounts =
            await _vault.importWallet(mnemonic: mnemonic, passcode: passcode);
        return _unlockedState(accounts);
      });

  Future<void> unlock(String passcode) => _run(() async {
        final accounts = await _vault.unlock(passcode);
        return _unlockedState(accounts);
      });

  void lock() {
    _vault.lock();
    state = state.copyWith(status: VaultStatus.locked, error: null);
  }

  Future<void> addAccount({String? label}) => _run(() async {
        final account = await _vault.addAccount(label: label);
        return state.copyWith(
          accounts: [...state.accounts, account],
          activeAccountIndex: account.index,
          status: VaultStatus.unlocked,
        );
      });

  void selectAccount(int index) =>
      state = state.copyWith(activeAccountIndex: index);

  void selectNetwork(Network network) =>
      state = state.copyWith(activeNetwork: network);

  Future<void> deleteWallet() => _run(() async {
        await _vault.deleteWallet();
        return const WalletSessionState(status: VaultStatus.noWallet);
      });

  WalletSessionState _unlockedState(List<WalletAccount> accounts) =>
      state.copyWith(
        status: VaultStatus.unlocked,
        accounts: accounts,
        activeAccountIndex: accounts.isNotEmpty ? accounts.first.index : 0,
        error: null,
      );

  /// Run an async action with busy/error bookkeeping. Rethrows so callers
  /// (e.g. a passcode screen) can show inline feedback.
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
    final s = e.toString();
    final i = s.indexOf(': ');
    return i >= 0 ? s.substring(i + 2) : s;
  }
}
