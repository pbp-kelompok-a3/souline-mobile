import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/studio_entry.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/navigation_bar.dart';
import '../../shared/widgets/left_drawer.dart';
import 'studio_form_page.dart';
import 'studio_service.dart';
import 'widgets/studio_card.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  final TextEditingController _searchController = TextEditingController();

  // Selected city filter (null means show user's city)
  UserKota? _selectedCity;
  String _searchQuery = '';
  bool _isFilterVisible = false;
  UserKota? _userCity;
  bool _hasUserKota = false;
  bool _isLoading = true;
  String? _error;
  bool _isAdmin = false;

  List<Studio> _allStudios = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<Studio> get _filteredStudios {
    final cityFilter = _selectedCity ?? _userCity;

    if (_userCity == null) return [];

    // Filter by city
    var studios = _allStudios
        .where((studio) => studio.kota == cityFilter)
        .toList();

    if (_searchQuery.isNotEmpty) {
      // Search across All cities
      studios = _allStudios.where((studio) {
        final query = _searchQuery.toLowerCase();
        return studio.namaStudio.toLowerCase().contains(query) ||
            studio.area.toLowerCase().contains(query) ||
            (userKotaValues.reverse[studio.kota]?.toLowerCase().contains(
                  query,
                ) ??
                false);
      }).toList();
    }

    return studios;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _isFilterVisible = false;
    });
  }

  void _onCityFilterChanged(UserKota? city) {
    setState(() {
      _selectedCity = city;
      _searchQuery = '';
      _searchController.clear();
      _isFilterVisible = false;
    });
  }

  void _toggleFilter() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  void _navigateToCreateStudio() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudioFormPage()),
    ).then((value) {
      if (value == true) _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();
      final service = StudioService(request);

      final entry = await service.fetchStudios();
      final admin = await service.isAdmin();

      if (!mounted) return;

      // Flatten studios from cities
      final studios = <Studio>[];
      for (final city in entry.cities) {
        studios.addAll(city.studios);
      }

      setState(() {
        _allStudios = studios;
        _userCity = entry.userKota;
        _hasUserKota = entry.hasUserKota;
        _isAdmin = admin;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load studios: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCity = _selectedCity ?? _userCity;
    final isSearching = _searchQuery.isNotEmpty;

    // Show loading or error state with AppHeader
    if (_isLoading || _error != null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        drawer: const LeftDrawer(),
        body: Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  title: 'Studio',
                  onSearchChanged: _onSearchChanged,
                  onFilterPressed: _toggleFilter,
                  showDrawerButton: true,
                ),
                Expanded(
                  child: _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.darkBlue,
                          ),
                        ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FloatingNavigationBar(currentIndex: 1),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      drawer: const LeftDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                title: 'Studio',
                onSearchChanged: _onSearchChanged,
                onFilterPressed: _toggleFilter,
                showDrawerButton: true,
              ),
              const SizedBox(height: 42),

              // City Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 8),
                    Text(
                      currentCity != null && !isSearching
                          ? '${userKotaValues.reverse[currentCity]}'
                          : 'Search Results',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    if (currentCity == _userCity &&
                        _hasUserKota &&
                        !isSearching)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          '(Your Location)',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.darkBlue,
                  child: _filteredStudios.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSearching
                                    ? Icons.search_off
                                    : Icons.fitness_center,
                                size: 64,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isSearching
                                    ? 'No studios found for "$_searchQuery"'
                                    : 'No studios in ${userKotaValues.reverse[currentCity]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount:
                              _filteredStudios.length + (isSearching ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (isSearching && index == 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Found ${_filteredStudios.length} studio${_filteredStudios.length != 1 ? 's' : ''} for "$_searchQuery"',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            }

                            final studioIndex = isSearching ? index - 1 : index;
                            return StudioCard(
                              studio: _filteredStudios[studioIndex],
                              isAdmin: _isAdmin,
                              onDeleted: _loadData,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
          if (_isFilterVisible)
            Positioned(
              top: 190,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: UserKota.values.map((city) {
                        final isSelected = city == (_selectedCity ?? _userCity);
                        return GestureDetector(
                          onTap: () => _onCityFilterChanged(city),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.darkBlue
                                  : const Color(0xFF7EB3DE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userKotaValues.reverse[city] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavigationBar(currentIndex: 1),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Adjust for navbar
        child: FloatingActionButton(
          heroTag: 'studio-fab',
          onPressed: _navigateToCreateStudio,
          backgroundColor: AppColors.orange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
