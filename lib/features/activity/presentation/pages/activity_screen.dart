import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../domain/activity_item.dart';
import '../providers/activity_provider.dart';

/// Transaction history (native SOL). Used as the History tab and pushable as a
/// standalone screen. Groups entries by day and links each to the explorer.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityProvider);
    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: activity.when(
                loading: () => const _ActivitySkeleton(),
                error: (_, __) =>
                    _ErrorView(onRetry: () => ref.invalidate(activityProvider)),
                data: (items) => items.isEmpty
                    ? const _EmptyView()
                    : RefreshIndicator(
                        color: NB.orange,
                        backgroundColor: NB.surface,
                        onRefresh: () => ref.refresh(activityProvider.future),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          children: _sections(context, ref, items),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(
      BuildContext context, WidgetRef ref, List<ActivityItem> items) {
    final widgets = <Widget>[];
    String? last;
    for (final item in items) {
      final label = _dateLabel(item.timestamp);
      if (label != last) {
        widgets.add(Padding(
          padding: EdgeInsets.only(top: widgets.isEmpty ? 8 : 22, bottom: 4),
          child: Text(label.toUpperCase(),
              style: NB.font(12,
                  weight: FontWeight.w700,
                  color: NB.text3,
                  letterSpacing: 0.5)),
        ));
        last = label;
      }
      widgets.add(_ActivityRow(
        item: item,
        onTap: () => _openExplorer(ref, item),
      ));
    }
    return widgets;
  }

  static String _dateLabel(DateTime? t) {
    if (t == null) return 'Earlier';
    final now = DateTime.now();
    final day = DateTime(t.year, t.month, t.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMM').format(t);
  }

  Future<void> _openExplorer(WidgetRef ref, ActivityItem item) async {
    if (item.signature.isEmpty) return;
    final cluster = ref.read(networkClusterProvider);
    final q = cluster.isMainnet ? '' : '?cluster=${cluster.id}';
    await launchUrl(Uri.parse('https://solscan.io/tx/${item.signature}$q'),
        mode: LaunchMode.externalApplication);
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 14, 6),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon:
                  const Icon(Icons.arrow_back_ios_new, size: 20, color: NB.text),
            )
          else
            const SizedBox(width: 44),
          Expanded(
            child: Text('Activity',
                textAlign: TextAlign.center,
                style: NB.font(18, weight: FontWeight.w800)),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, required this.onTap});

  final ActivityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final received = item.isReceived;
    final counterparty =
        item.counterparty.isEmpty ? 'Unknown' : Fmt.address(item.counterparty);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            const CoinLogo(network: Network.solana, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(received ? 'Received' : 'Sent',
                      style: NB.font(15.5, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${received ? 'From' : 'To'}:  $counterparty',
                      style: NB.font(13, color: NB.text2)),
                ],
              ),
            ),
            Text(
              '${received ? '+' : '-'}${Fmt.tokenAmount(item.amountSol)} SOL',
              style: NB.font(15,
                  weight: FontWeight.w700,
                  color: received ? NB.green : NB.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 44, color: NB.text3),
            const SizedBox(height: 16),
            Text('No activity yet',
                style: NB.font(16, weight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Your SOL transactions will show up here.',
                textAlign: TextAlign.center,
                style: NB.font(13.5, color: NB.text2)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44, color: NB.text3),
            const SizedBox(height: 16),
            Text('Couldn\'t load activity',
                style: NB.font(16, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onRetry,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: NB.surface2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Retry',
                    style: NB.font(14, weight: FontWeight.w700, color: NB.text)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        for (var i = 0; i < 8; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                Skeleton.circle(44),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 90, height: 15),
                    SizedBox(height: 7),
                    Skeleton(width: 120, height: 12),
                  ],
                ),
                Spacer(),
                Skeleton(width: 70, height: 15),
              ],
            ),
          ),
      ],
    );
  }
}
