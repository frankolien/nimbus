import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/shared/data/models/dapp_data.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'Defi';

  final List<String> _tabs = [
    'Favourites',
    'Defi',
    'Staking',
    'Bridge',
    'Lending',
    'Dex',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getAssetPath(String dappName) {
    // Convert DApp name to lowercase and replace special characters for asset path
    String assetName = dappName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('.', '_')
        .replaceAll('-', '_');
    return 'assets/images/${assetName}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar
            //_buildStatusBar(),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // DApp Grid
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1F22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3A3A3C),
                    width: 1,
                  ),
                ),
                child: _buildDAppGrid(),
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Tabs
            _buildNavigationTabs(),
            const SizedBox(height: 16),

            // Protocols List
            Expanded(
              child: _buildProtocolsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            hintText: 'search or type a url',
            hintStyle: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDAppGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: DAppData.dappGrid.length,
        itemBuilder: (context, index) {
          final dapp = DAppData.dappGrid[index];
          return Column(
            children: [
              ClipOval(
                child: Image.network(
                  dapp['logoUrl'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                        'Network image failed for ${dapp['name']}, using asset fallback');
                    return Image.asset(
                      _getAssetPath(dapp['name']),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Asset image also failed for ${dapp['name']}');
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(dapp['color']),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.apps,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dapp['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = tab == _selectedTab;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                child: Column(
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF8E8E93),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 2,
                        width: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(1)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProtocolsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: DAppData.protocols.length,
      itemBuilder: (context, index) {
        final protocol = DAppData.protocols[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(protocol['color']),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    protocol['logoUrl'],
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print(
                          'Network image failed for ${protocol['name']}, using asset fallback');
                      return Image.asset(
                        _getAssetPath(protocol['name']),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                              'Asset image also failed for ${protocol['name']}');
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(protocol['color']),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.apps,
                              color: Colors.white,
                              size: 20,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      protocol['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      protocol['description'],
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.star_border,
                color: const Color(0xFF8E8E93),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
