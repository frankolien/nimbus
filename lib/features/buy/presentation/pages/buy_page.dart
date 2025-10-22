import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuyPage extends ConsumerWidget {
  const BuyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Crypto'),
      ),
      body: const Center(
        child: Text('Buy Page - Coming Soon'),
      ),
    );
  }
}
