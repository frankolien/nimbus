import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../data/services/purchase_tracking_service.dart';

class PurchaseStatusScreen extends ConsumerStatefulWidget {
  const PurchaseStatusScreen({super.key});

  @override
  ConsumerState<PurchaseStatusScreen> createState() =>
      _PurchaseStatusScreenState();
}

class _PurchaseStatusScreenState extends ConsumerState<PurchaseStatusScreen> {
  Timer? _refreshTimer;
  List<PurchaseRecord> _pendingPurchases = [];
  List<PurchaseRecord> _completedPurchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadPurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pending = await PurchaseTrackingService.getPendingPurchases();
      final completed = await PurchaseTrackingService.getCompletedPurchases();

      setState(() {
        _pendingPurchases = pending;
        _completedPurchases = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading purchases: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (mounted) {
        final completed =
            await PurchaseTrackingService.checkForCompletedPurchases();
        if (completed.isNotEmpty) {
          _loadPurchases();

          // Show notification for completed purchases
          for (final purchase in completed) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ ${purchase.cryptoAmount} ${purchase.cryptoAsset} purchase completed!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Purchase Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPurchases,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadPurchases();
              },
              color: const Color(0xFFFF6B35),
              backgroundColor: const Color(0xFF1A1A1A),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Pending Purchases Section
                  if (_pendingPurchases.isNotEmpty) ...[
                    _buildSectionHeader(
                        'Pending Purchases', _pendingPurchases.length),
                    const SizedBox(height: 12),
                    ..._pendingPurchases.map((purchase) =>
                        _buildPurchaseCard(purchase, isPending: true)),
                    const SizedBox(height: 24),
                  ],

                  // Completed Purchases Section
                  if (_completedPurchases.isNotEmpty) ...[
                    _buildSectionHeader(
                        'Recent Purchases', _completedPurchases.length),
                    const SizedBox(height: 12),
                    ..._completedPurchases.take(5).map((purchase) =>
                        _buildPurchaseCard(purchase, isPending: false)),
                  ],

                  // Empty State
                  if (_pendingPurchases.isEmpty && _completedPurchases.isEmpty)
                    _buildEmptyState(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseCard(PurchaseRecord purchase,
      {required bool isPending}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? const Color(0xFFFF6B35) : const Color(0xFF333333),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status Indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),

              // Provider Name
              Text(
                purchase.providerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Amount
              Text(
                '${purchase.cryptoAmount} ${purchase.cryptoAsset}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Details
          Row(
            children: [
              Text(
                'Amount: \$${purchase.fiatAmount} ${purchase.fiatCurrency}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                isPending
                    ? 'Expected: ${_formatTime(purchase.expectedCompletionTime)}'
                    : 'Completed: ${_formatTime(purchase.completedAt!)}',
                style: TextStyle(
                  color: isPending ? Colors.orange : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (isPending) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _calculateProgress(purchase),
              backgroundColor: const Color(0xFF333333),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No purchases yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your crypto purchases will appear here',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy Crypto'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  double _calculateProgress(PurchaseRecord purchase) {
    final now = DateTime.now();
    final total =
        purchase.expectedCompletionTime.difference(purchase.createdAt);
    final elapsed = now.difference(purchase.createdAt);

    if (elapsed.inMilliseconds >= total.inMilliseconds) {
      return 1.0;
    }

    return elapsed.inMilliseconds / total.inMilliseconds;
  }
}
