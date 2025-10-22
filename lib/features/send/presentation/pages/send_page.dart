import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendPage extends ConsumerWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Crypto'),
      ),
      body: const Center(
        child: Text('Send Page - Coming Soon'),
      ),
    );
  }
}
