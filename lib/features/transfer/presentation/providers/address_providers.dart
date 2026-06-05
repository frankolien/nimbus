import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../wallet/domain/entities/chain_family.dart';
import '../../data/address_store.dart';
import '../../domain/recent_recipient.dart';
import '../../domain/saved_address.dart';

final addressStoreProvider = Provider((ref) => AddressStore());

/// The manual address book (saved + named recipients), persisted.
class SavedAddressesNotifier extends StateNotifier<List<SavedAddress>> {
  SavedAddressesNotifier(this._store) : super(const []) {
    _load();
  }

  final AddressStore _store;

  Future<void> _load() async => state = await _store.loadSaved();

  Future<void> add(SavedAddress entry) =>
      _persist([...state.where((e) => !e.sameAs(entry.address, entry.family)), entry]);

  Future<void> remove(SavedAddress entry) =>
      _persist(state.where((e) => !e.sameAs(entry.address, entry.family)).toList());

  Future<void> replace(SavedAddress previous, SavedAddress next) => _persist([
        for (final e in state)
          e.sameAs(previous.address, previous.family) ? next : e,
      ]);

  Future<void> _persist(List<SavedAddress> next) async {
    state = next;
    await _store.saveSaved(next);
  }
}

final savedAddressesProvider =
    StateNotifierProvider<SavedAddressesNotifier, List<SavedAddress>>(
        (ref) => SavedAddressesNotifier(ref.watch(addressStoreProvider)));

/// Auto-tracked recent recipients (newest first).
class RecentRecipientsNotifier extends StateNotifier<List<RecentRecipient>> {
  RecentRecipientsNotifier(this._store) : super(const []) {
    _load();
  }

  final AddressStore _store;

  Future<void> _load() async => state = await _store.loadRecents();

  /// Record a successful send so it surfaces at the top next time.
  Future<void> record(String address, ChainFamily family) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final next = [
      RecentRecipient(address: address, family: family, lastUsedAt: now),
      ...state.where((e) => !(e.address == address && e.family == family)),
    ];
    state = next;
    await _store.saveRecents(next);
  }
}

final recentRecipientsProvider =
    StateNotifierProvider<RecentRecipientsNotifier, List<RecentRecipient>>(
        (ref) => RecentRecipientsNotifier(ref.watch(addressStoreProvider)));
