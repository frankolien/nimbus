import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/portfolio/data/rpc_endpoints.dart';
import 'package:nimbus/features/wallet/domain/entities/network.dart';
import 'package:nimbus/features/wallet/domain/entities/network_cluster.dart';

void main() {
  // Empty env so the mainnet `.env` override path resolves to the public default.
  setUpAll(() => dotenv.testLoad(fileInput: ''));

  const endpoints = RpcEndpoints();

  test('resolves Solana per cluster', () {
    expect(endpoints.urlFor(Network.solana, NetworkCluster.mainnet),
        'https://api.mainnet-beta.solana.com');
    expect(endpoints.urlFor(Network.solana, NetworkCluster.devnet),
        'https://api.devnet.solana.com');
    expect(endpoints.urlFor(Network.solana, NetworkCluster.testnet),
        'https://api.testnet.solana.com');
  });

  test('defaults to mainnet when no cluster is given', () {
    expect(endpoints.urlFor(Network.solana),
        'https://api.mainnet-beta.solana.com');
  });

  test('EVM has no devnet — falls back to its testnet (Sepolia)', () {
    final url = endpoints.urlFor(Network.ethereum, NetworkCluster.devnet);
    expect(url.contains('sepolia'), isTrue);
    expect(url, endpoints.urlFor(Network.ethereum, NetworkCluster.testnet));
  });

  test('Bitcoin devnet falls back to testnet REST base', () {
    expect(endpoints.urlFor(Network.bitcoin, NetworkCluster.devnet),
        'https://mempool.space/testnet/api');
  });

  test('Sui resolves a devnet fullnode', () {
    expect(endpoints.urlFor(Network.sui, NetworkCluster.devnet),
        'https://fullnode.devnet.sui.io');
  });
}
