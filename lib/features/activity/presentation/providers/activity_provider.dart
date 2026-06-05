import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../data/solana_activity_service.dart';
import '../../domain/activity_item.dart';

final solanaActivityServiceProvider = Provider((ref) => SolanaActivityService());

/// Native-SOL history for the active account's Solana address on the active
/// cluster. Re-fetches when the account or cluster changes; refreshable via
/// `ref.refresh`.
final activityProvider = FutureProvider.autoDispose<List<ActivityItem>>((ref) {
  final account =
      ref.watch(walletSessionProvider.select((s) => s.activeAccount));
  final cluster = ref.watch(networkClusterProvider);
  final address = account?.account(ChainFamily.solana)?.address;
  if (address == null) return Future.value(const <ActivityItem>[]);
  return ref
      .watch(solanaActivityServiceProvider)
      .fetch(address: address, cluster: cluster);
});
