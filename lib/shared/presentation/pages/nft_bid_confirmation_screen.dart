import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../entities/nft.dart';

class NFTBidConfirmationScreen extends StatelessWidget {
  final NFT nft;
  final Map<String, dynamic> bidResult;

  const NFTBidConfirmationScreen({
    super.key,
    required this.nft,
    required this.bidResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Colors.blue,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Success Title
              const Text(
                'Bid Placed Successfully!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Your bid is now active',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // NFT Card
              _buildNFTCard(),

              const SizedBox(height: 32),

              // Bid Details
              _buildBidDetails(context),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNFTCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: Column(
        children: [
          // NFT Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[800],
              child: nft.imageUrl.isNotEmpty
                  ? Image.network(
                      nft.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.grey[400],
                                size: 60,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                nft.name,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nft.name,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // NFT Info
          Text(
            nft.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Text(
            nft.collectionName,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFFF6B35),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBidDetails(BuildContext context) {
    final bidId = bidResult['bidId'] as String?;
    final bidAmount = bidResult['bidAmount'] as double?;
    final transactionHash = bidResult['transactionHash'] as String?;
    final gasUsed = bidResult['gasUsed'] as String?;
    final gasPrice = bidResult['gasPrice'] as String?;
    final expirationTime = bidResult['expirationTime'] as DateTime?;
    final isHighestBid = bidResult['isHighestBid'] as bool?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bid Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          _buildBidRow(
              'Bid Amount', '${bidAmount?.toStringAsFixed(4) ?? '0.0000'} ETH'),
          _buildBidRow('Bid ID', bidId ?? 'N/A'),
          _buildBidRow(
              'Status', isHighestBid == true ? 'Highest Bid' : 'Active Bid'),
          _buildBidRow('Expires', _formatDate(expirationTime)),
          _buildBidRow('Gas Used', '${gasUsed ?? '0'}'),
          _buildBidRow('Gas Price', '${gasPrice ?? '0'} Gwei'),

          const SizedBox(height: 16),

          // Transaction Hash
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Hash',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transactionHash ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF6B35),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: transactionHash ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Transaction hash copied to clipboard'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        color: Color(0xFFFF6B35),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can increase your bid anytime before expiration. You will be notified if someone outbids you.',
                    style: TextStyle(
                      color: Colors.blue[300],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // View NFT Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Could navigate to NFT details or portfolio
            },
            icon: const Icon(Icons.visibility, size: 20),
            label: const Text('View NFT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Increase Bid Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Increase bid functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Increase bid functionality coming soon!'),
                  backgroundColor: Color(0xFFFF6B35),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.trending_up, size: 20),
            label: const Text('Increase Bid'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B35),
              side: const BorderSide(color: Color(0xFFFF6B35)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Done Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
