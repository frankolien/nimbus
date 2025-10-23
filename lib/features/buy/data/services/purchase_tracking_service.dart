import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PurchaseTrackingService {
  static const _storage = FlutterSecureStorage();
  static const String _pendingPurchasesKey = 'pending_purchases';
  static const String _completedPurchasesKey = 'completed_purchases';

  /// Track a pending purchase when user redirects to payment provider
  static Future<void> trackPendingPurchase({
    required String providerName,
    required String cryptoAsset,
    required String cryptoAmount,
    required String fiatAmount,
    required String fiatCurrency,
    required String walletAddress,
    required String purchaseUrl,
  }) async {
    try {
      final purchase = PurchaseRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        providerName: providerName,
        cryptoAsset: cryptoAsset,
        cryptoAmount: cryptoAmount,
        fiatAmount: fiatAmount,
        fiatCurrency: fiatCurrency,
        walletAddress: walletAddress,
        purchaseUrl: purchaseUrl,
        status: PurchaseStatus.pending,
        createdAt: DateTime.now(),
        expectedCompletionTime: DateTime.now().add(const Duration(minutes: 15)),
      );

      final pendingPurchases = await getPendingPurchases();
      pendingPurchases.add(purchase);

      await _storage.write(
        key: _pendingPurchasesKey,
        value: jsonEncode(pendingPurchases.map((p) => p.toJson()).toList()),
      );

      print('📝 Tracked pending purchase: ${purchase.id}');
    } catch (e) {
      print('❌ Error tracking pending purchase: $e');
    }
  }

  /// Mark a purchase as completed and update balances
  static Future<void> markPurchaseCompleted({
    required String purchaseId,
    required String transactionHash,
    required double actualCryptoAmount,
  }) async {
    try {
      final pendingPurchases = await getPendingPurchases();
      final completedPurchases = await getCompletedPurchases();

      final purchaseIndex =
          pendingPurchases.indexWhere((p) => p.id == purchaseId);
      if (purchaseIndex == -1) {
        print('❌ Purchase not found: $purchaseId');
        return;
      }

      final purchase = pendingPurchases[purchaseIndex];
      purchase.status = PurchaseStatus.completed;
      purchase.transactionHash = transactionHash;
      purchase.actualCryptoAmount = actualCryptoAmount;
      purchase.completedAt = DateTime.now();

      // Move to completed purchases
      completedPurchases.add(purchase);
      pendingPurchases.removeAt(purchaseIndex);

      // Save both lists
      await _storage.write(
        key: _pendingPurchasesKey,
        value: jsonEncode(pendingPurchases.map((p) => p.toJson()).toList()),
      );

      await _storage.write(
        key: _completedPurchasesKey,
        value: jsonEncode(completedPurchases.map((p) => p.toJson()).toList()),
      );

      print('✅ Purchase completed: ${purchase.id}');
    } catch (e) {
      print('❌ Error completing purchase: $e');
    }
  }

  /// Get all pending purchases
  static Future<List<PurchaseRecord>> getPendingPurchases() async {
    try {
      final data = await _storage.read(key: _pendingPurchasesKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => PurchaseRecord.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error reading pending purchases: $e');
      return [];
    }
  }

  /// Get all completed purchases
  static Future<List<PurchaseRecord>> getCompletedPurchases() async {
    try {
      final data = await _storage.read(key: _completedPurchasesKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => PurchaseRecord.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error reading completed purchases: $e');
      return [];
    }
  }

  /// Check for completed purchases and update balances
  static Future<List<PurchaseRecord>> checkForCompletedPurchases() async {
    try {
      final pendingPurchases = await getPendingPurchases();
      final now = DateTime.now();

      // Find purchases that should be completed by now
      final completedPurchases = <PurchaseRecord>[];

      for (final purchase in pendingPurchases) {
        if (now.isAfter(purchase.expectedCompletionTime)) {
          // Simulate checking blockchain for completion
          final isCompleted = await _simulateBlockchainCheck(purchase);

          if (isCompleted) {
            purchase.status = PurchaseStatus.completed;
            purchase.completedAt = now;
            completedPurchases.add(purchase);
          }
        }
      }

      // Update storage if any purchases were completed
      if (completedPurchases.isNotEmpty) {
        final remainingPending = pendingPurchases
            .where((p) => !completedPurchases.contains(p))
            .toList();

        await _storage.write(
          key: _pendingPurchasesKey,
          value: jsonEncode(remainingPending.map((p) => p.toJson()).toList()),
        );

        final allCompleted = await getCompletedPurchases();
        allCompleted.addAll(completedPurchases);

        await _storage.write(
          key: _completedPurchasesKey,
          value: jsonEncode(allCompleted.map((p) => p.toJson()).toList()),
        );
      }

      return completedPurchases;
    } catch (e) {
      print('❌ Error checking completed purchases: $e');
      return [];
    }
  }

  /// Simulate blockchain check (in real implementation, this would check actual blockchain)
  static Future<bool> _simulateBlockchainCheck(PurchaseRecord purchase) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate 80% success rate
    return DateTime.now().millisecondsSinceEpoch % 5 != 0;
  }

  /// Clear old completed purchases (older than 30 days)
  static Future<void> clearOldPurchases() async {
    try {
      final completedPurchases = await getCompletedPurchases();
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final recentPurchases = completedPurchases
          .where((p) => p.completedAt?.isAfter(thirtyDaysAgo) ?? false)
          .toList();

      await _storage.write(
        key: _completedPurchasesKey,
        value: jsonEncode(recentPurchases.map((p) => p.toJson()).toList()),
      );

      print(
          '🧹 Cleared old purchases, kept ${recentPurchases.length} recent ones');
    } catch (e) {
      print('❌ Error clearing old purchases: $e');
    }
  }
}

class PurchaseRecord {
  final String id;
  final String providerName;
  final String cryptoAsset;
  final String cryptoAmount;
  final String fiatAmount;
  final String fiatCurrency;
  final String walletAddress;
  final String purchaseUrl;
  PurchaseStatus status;
  final DateTime createdAt;
  final DateTime expectedCompletionTime;
  DateTime? completedAt;
  String? transactionHash;
  double? actualCryptoAmount;

  PurchaseRecord({
    required this.id,
    required this.providerName,
    required this.cryptoAsset,
    required this.cryptoAmount,
    required this.fiatAmount,
    required this.fiatCurrency,
    required this.walletAddress,
    required this.purchaseUrl,
    required this.status,
    required this.createdAt,
    required this.expectedCompletionTime,
    this.completedAt,
    this.transactionHash,
    this.actualCryptoAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerName': providerName,
      'cryptoAsset': cryptoAsset,
      'cryptoAmount': cryptoAmount,
      'fiatAmount': fiatAmount,
      'fiatCurrency': fiatCurrency,
      'walletAddress': walletAddress,
      'purchaseUrl': purchaseUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expectedCompletionTime': expectedCompletionTime.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionHash': transactionHash,
      'actualCryptoAmount': actualCryptoAmount,
    };
  }

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'],
      providerName: json['providerName'],
      cryptoAsset: json['cryptoAsset'],
      cryptoAmount: json['cryptoAmount'],
      fiatAmount: json['fiatAmount'],
      fiatCurrency: json['fiatCurrency'],
      walletAddress: json['walletAddress'],
      purchaseUrl: json['purchaseUrl'],
      status: PurchaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PurchaseStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      expectedCompletionTime: DateTime.parse(json['expectedCompletionTime']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      transactionHash: json['transactionHash'],
      actualCryptoAmount: json['actualCryptoAmount']?.toDouble(),
    );
  }
}

enum PurchaseStatus {
  pending,
  completed,
  failed,
  cancelled,
}
