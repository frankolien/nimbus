import 'package:equatable/equatable.dart';

class SwapQuote extends Equatable {
  final String sellToken;
  final String buyToken;
  final String sellAmount;
  final String buyAmount;
  final String price;
  final String gasPrice;
  final String gas;
  final String allowanceTarget;
  final String to;
  final String data;
  final String value;
  final String estimatedGas;
  final String protocolFee;
  final String minimumProtocolFee;
  final String buyTokenToEthRate;
  final String sellTokenToEthRate;

  const SwapQuote({
    required this.sellToken,
    required this.buyToken,
    required this.sellAmount,
    required this.buyAmount,
    required this.price,
    required this.gasPrice,
    required this.gas,
    required this.allowanceTarget,
    required this.to,
    required this.data,
    required this.value,
    required this.estimatedGas,
    required this.protocolFee,
    required this.minimumProtocolFee,
    required this.buyTokenToEthRate,
    required this.sellTokenToEthRate,
  });

  @override
  List<Object?> get props => [
        sellToken,
        buyToken,
        sellAmount,
        buyAmount,
        price,
        gasPrice,
        gas,
        allowanceTarget,
        to,
        data,
        value,
        estimatedGas,
        protocolFee,
        minimumProtocolFee,
        buyTokenToEthRate,
        sellTokenToEthRate,
      ];
}
