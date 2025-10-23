import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/send_provider.dart';

class AddressInputScreen extends ConsumerStatefulWidget {
  const AddressInputScreen({super.key});

  @override
  ConsumerState<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends ConsumerState<AddressInputScreen> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendNotifierProvider);
    final sendNotifier = ref.read(sendNotifierProvider.notifier);

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address Input Section
                _buildAddressInput(sendNotifier),

                const SizedBox(height: 24),

                // Recent Transfers Section
                _buildRecentTransfers(),

                const SizedBox(height: 24),

                // Saved Addresses Section
                _buildSavedAddresses(),

                const SizedBox(height: 24), // Extra padding at bottom
              ],
            ),
          ),
        ),

        // Fixed Continue Button
        Container(
          padding: const EdgeInsets.all(16.0),
          child: _buildContinueButton(sendState, sendNotifier),
        ),
      ],
    );
  }

  Widget _buildAddressInput(SendNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter address',
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: const Icon(Icons.contacts, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B35)),
            ),
          ),
          onChanged: (value) => notifier.updateRecipientAddress(value),
        ),
      ],
    );
  }

  Widget _buildRecentTransfers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent transfers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(color: Color(0xFFFF6B35)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTransferItem('stepprofile', 'TCsMaX.....pimpc'),
        _buildTransferItem('Emerie.sol', 'TCsMaX......pimpc'),
        _buildTransferItem('XOhhsu...plqawe', 'TCsMaX......pimpc'),
      ],
    );
  }

  Widget _buildSavedAddresses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My saved address',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildSavedAddressItem('My okx sol address', 'Zx97nl...09pUyv'),
        _buildSavedAddressItem('Mine', 'TCsMaX...plmapc'),
        _buildSavedAddressItem('Chinnie Funds', 'mzSqOP...oa092'),
        _buildSavedAddressItem('Just rite', 'lokMnA...UytREQ'),
        _buildSavedAddressItem('Jendol supermarket', 'pqla27...plwmpc'),
        _buildSavedAddressItem('Pelumi mechanic', 'WAzint...90uJag'),
      ],
    );
  }

  Widget _buildTransferItem(String name, String address) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        address,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      onTap: () {
        _addressController.text = address;
        ref.read(sendNotifierProvider.notifier).updateRecipientAddress(address);
        ref.read(sendNotifierProvider.notifier).updateRecipientName(name);
      },
    );
  }

  Widget _buildSavedAddressItem(String name, String address) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.bookmark,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        address,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      onTap: () {
        _addressController.text = address;
        ref.read(sendNotifierProvider.notifier).updateRecipientAddress(address);
        ref.read(sendNotifierProvider.notifier).updateRecipientName(name);
      },
    );
  }

  Widget _buildContinueButton(SendStateData state, SendNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: notifier.canProceedForStep(SendStep.addressInput)
            ? () => notifier.nextStep()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: notifier.canProceedForStep(SendStep.addressInput)
              ? const Color(0xFFFF6B35)
              : const Color(0xFF444444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
