import '../entities/buy_order.dart';

abstract class BuyRepository {
  Future<BuyOrder> createBuyOrder({
    required String tokenSymbol,
    required double amount,
    required String paymentMethod,
  });

  Future<List<BuyOrder>> getBuyHistory();
  Future<BuyOrder> getBuyOrder(String orderId);
  Future<void> cancelBuyOrder(String orderId);
}
