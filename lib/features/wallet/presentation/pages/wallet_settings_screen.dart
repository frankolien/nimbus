import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:nimbus/features/wallet/data/services/custodial_wallet_service.dart';

class WalletSettingsScreen extends ConsumerStatefulWidget {
  const WalletSettingsScreen({super.key});

  @override
  ConsumerState<WalletSettingsScreen> createState() =>
      _WalletSettingsScreenState();
}

class _WalletSettingsScreenState extends ConsumerState<WalletSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'Wallet Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Info Section
            _buildSectionTitle('Wallet Information'),
            const SizedBox(height: 16),
            _buildWalletInfoCard(),

            const SizedBox(height: 32),

            // Security Section
            _buildSectionTitle('Security'),
            const SizedBox(height: 16),
            _buildSecurityOptions(),

            const SizedBox(height: 32),

            // Danger Zone
            _buildSectionTitle('Danger Zone'),
            const SizedBox(height: 16),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildWalletInfoCard() {
    return Consumer(
      builder: (context, ref, child) {
        final walletState = ref.watch(walletStateProvider);

        if (walletState.hasValue && walletState.value != null) {
          final wallet = walletState.value!;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFF9C27B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Wallet Address',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.address,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white70),
                      onPressed: () =>
                          _copyToClipboard(wallet.address, 'Address'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Balance: ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${wallet.balance?.toStringAsFixed(4) ?? '0.0000'} ETH',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return const Center(
          child: Text(
            'No wallet connected',
            style: TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }

  Widget _buildSecurityOptions() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.key,
          title: 'View Private Key',
          subtitle: 'Show your wallet\'s private key for backup',
          onTap: _showPrivateKeyDialog,
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.security,
          title: 'Export Wallet',
          subtitle: 'Export wallet data for backup',
          onTap: _exportWallet,
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.delete_forever,
          title: 'Delete Wallet',
          subtitle: 'Permanently delete this wallet (cannot be undone)',
          textColor: Colors.red,
          onTap: _deleteWallet,
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showPrivateKeyDialog() async {
    try {
      final custodialService = ref.read(custodialWalletServiceProvider);
      const userId = 'user_123'; // In production, this would come from auth

      final wallet = await custodialService.loadWallet(userId);
      if (wallet == null) {
        _showErrorSnackBar('Wallet not found');
        return;
      }

      // Get the private key as hex string
      final privateKeyHex =
          '0x${wallet.privateKey.privateKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PrivateKeyDialog(privateKey: privateKeyHex),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load private key: $e');
    }
  }

  Future<void> _exportWallet() async {
    try {
      final custodialService = ref.read(custodialWalletServiceProvider);
      const userId = 'user_123';

      final wallet = await custodialService.loadWallet(userId);
      if (wallet == null) {
        _showErrorSnackBar('Wallet not found');
        return;
      }

      final privateKeyHex =
          '0x${wallet.privateKey.privateKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

      final exportData = '''
Wallet Export Data
==================

Address: ${wallet.address}
Private Key: $privateKeyHex
Mnemonic: ${wallet.mnemonic}

⚠️  IMPORTANT SECURITY WARNING ⚠️
- Never share your private key with anyone
- Store this information in a secure location
- Anyone with your private key can access your funds
- Consider using a hardware wallet for large amounts

Generated on: ${DateTime.now().toString()}
''';

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ExportWalletDialog(exportData: exportData),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to export wallet: $e');
    }
  }

  Future<void> _deleteWallet() async {
    if (mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Delete Wallet',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Are you sure you want to delete this wallet? This action cannot be undone and you will lose access to all funds.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          final custodialService = ref.read(custodialWalletServiceProvider);
          const userId = 'user_123';

          await custodialService.deleteWallet(userId);

          // Clear wallet state
          ref.read(walletStateProvider.notifier).disconnectWallet();

          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          }
        } catch (e) {
          _showErrorSnackBar('Failed to delete wallet: $e');
        }
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessSnackBar('$label copied to clipboard');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class PrivateKeyDialog extends StatefulWidget {
  final String privateKey;

  const PrivateKeyDialog({super.key, required this.privateKey});

  @override
  State<PrivateKeyDialog> createState() => _PrivateKeyDialogState();
}

class _PrivateKeyDialogState extends State<PrivateKeyDialog> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text(
        'Private Key',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ SECURITY WARNING ⚠️\n\nNever share your private key with anyone. Anyone with this key can access your funds.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isVisible ? widget.privateKey : '•' * 66,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.privateKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Private key copied to clipboard'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

class ExportWalletDialog extends StatelessWidget {
  final String exportData;

  const ExportWalletDialog({super.key, required this.exportData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text(
        'Export Wallet',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Text(
              exportData,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: exportData));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Wallet data copied to clipboard'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Copy', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
