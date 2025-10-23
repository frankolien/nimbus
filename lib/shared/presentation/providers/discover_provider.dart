import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/shared/data/services/dapp_service.dart';

class DiscoverState {
  final String selectedTab;
  final String searchQuery;
  final List<DApp> filteredProtocols;
  final bool isLoading;
  final DateTime lastUpdated;

  DiscoverState({
    this.selectedTab = 'Defi',
    this.searchQuery = '',
    this.filteredProtocols = const [],
    this.isLoading = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  DiscoverState copyWith({
    String? selectedTab,
    String? searchQuery,
    List<DApp>? filteredProtocols,
    bool? isLoading,
    DateTime? lastUpdated,
  }) {
    return DiscoverState(
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredProtocols: filteredProtocols ?? this.filteredProtocols,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class DiscoverNotifier extends StateNotifier<DiscoverState> {
  DiscoverNotifier() : super(DiscoverState()) {
    _initializeData();
  }

  void _initializeData() {
    _updateFilteredProtocols();
  }

  void selectTab(String tab) {
    state = state.copyWith(selectedTab: tab);
    _updateFilteredProtocols();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _updateFilteredProtocols();
  }

  void _updateFilteredProtocols() {
    List<DApp> protocols;

    if (state.selectedTab == 'Favourites') {
      protocols = DAppService.getFavorites();
    } else if (state.searchQuery.isNotEmpty) {
      protocols = DAppService.searchProtocols(state.searchQuery);
    } else {
      protocols = DAppService.getProtocolsByCategory(state.selectedTab);
    }

    state = state.copyWith(filteredProtocols: protocols);
  }

  void toggleFavorite(String name) {
    DAppService.toggleFavorite(name);
    _updateFilteredProtocols();
  }

  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);

    try {
      await DAppService.fetchRealTimeData();
      _updateFilteredProtocols();
      state = state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    _updateFilteredProtocols();
  }
}

final discoverProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  return DiscoverNotifier();
});

final dappGridProvider = Provider<List<DApp>>((ref) {
  try {
    return DAppService.getDAppGrid();
  } catch (e) {
    return [];
  }
});

final categoriesProvider = Provider<List<String>>((ref) {
  try {
    return DAppService.getCategories();
  } catch (e) {
    return ['Favourites', 'Defi', 'Staking', 'Bridge', 'Lending', 'Dex'];
  }
});
