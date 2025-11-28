import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/studio_entry.dart';
import '../../shared/widgets/studio_card.dart';
import 'studio_form_page.dart';

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

  // TODO: Replace with actual data from API
  // Mock data for UI development
  final UserKota _userCity = UserKota.JAKARTA;

  final List<Studio> _allStudios = [
    Studio(
      id: '1',
      namaStudio: 'Yoga Studio Kemang',
      thumbnail:
          'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=400',
      kota: UserKota.JAKARTA,
      area: 'Kemang',
      alamat: 'Jl. Kemang Raya No. 10',
      gmapsLink: 'https://maps.google.com/?q=Kemang+Jakarta',
      nomorTelepon: '021-7654321',
      rating: 4.8,
    ),
    Studio(
      id: '2',
      namaStudio: 'Pilates Center Sudirman',
      thumbnail:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      kota: UserKota.JAKARTA,
      area: 'Sudirman',
      alamat: 'Jl. Jend. Sudirman No. 45',
      gmapsLink: 'https://maps.google.com/?q=Sudirman+Jakarta',
      nomorTelepon: '021-5551234',
      rating: 4.5,
    ),
    Studio(
      id: '3',
      namaStudio: 'Zen Yoga Bogor',
      thumbnail:
          'https://images.unsplash.com/photo-1588286840104-8957b019727f?w=400',
      kota: UserKota.BOGOR,
      area: 'Bogor Tengah',
      alamat: 'Jl. Pajajaran No. 20',
      gmapsLink: 'https://maps.google.com/?q=Pajajaran+Bogor',
      nomorTelepon: '0251-8765432',
      rating: 5.0,
    ),
    Studio(
      id: '4',
      namaStudio: 'Flow Studio Depok',
      thumbnail:
          'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=400',
      kota: UserKota.DEPOK,
      area: 'Margonda',
      alamat: 'Jl. Margonda Raya No. 100',
      gmapsLink: 'https://maps.google.com/?q=Margonda+Depok',
      nomorTelepon: '021-77889900',
      rating: 4.2,
    ),
    Studio(
      id: '5',
      namaStudio: 'Harmony Yoga Bekasi',
      thumbnail:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
      kota: UserKota.BEKASI,
      area: 'Summarecon',
      alamat: 'Jl. Boulevard Ahmad Yani, Summarecon Bekasi',
      gmapsLink: 'https://maps.google.com/?q=Summarecon+Bekasi',
      nomorTelepon: '021-29001234',
      rating: 4.7,
    ),
    Studio(
      id: '6',
      namaStudio: 'Balance Studio Tangerang',
      thumbnail:
          'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?w=400',
      kota: UserKota.TANGERANG,
      area: 'BSD City',
      alamat: 'Jl. BSD Green Office Park',
      gmapsLink: 'https://maps.google.com/?q=BSD+Tangerang',
      nomorTelepon: '021-53001234',
      rating: 3.9,
    ),
  ];

  List<Studio> get _filteredStudios {
    // Get the city to filter by
    final cityFilter = _selectedCity ?? _userCity;

    // Filter by city
    var studios = _allStudios
        .where((studio) => studio.kota == cityFilter)
        .toList();

    // Apply search filter if there's a search query
    if (_searchQuery.isNotEmpty) {
      // When searching, search across ALL cities
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
    });
  }

  void _onCityFilterChanged(UserKota? city) {
    setState(() {
      _selectedCity = city;
      _searchQuery = ''; // Clear search when changing city filter
      _searchController.clear();
    });
  }

  void _navigateToCreateStudio() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudioFormPage()),
    );
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

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text(
          'Studio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sticky search bar and filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search studios...',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.darkBlue,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // City filter dropdown
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserKota>(
                      value: currentCity,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      dropdownColor: AppColors.teal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (UserKota? newValue) {
                        if (newValue != null) {
                          _onCityFilterChanged(newValue);
                        }
                      },
                      items: UserKota.values.map((UserKota city) {
                        final cityName = userKotaValues.reverse[city] ?? '';
                        final isUserCity = city == _userCity;
                        return DropdownMenuItem<UserKota>(
                          value: city,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cityName),
                              if (isUserCity) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.home,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Studios list
          Expanded(
            child: _filteredStudios.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSearching ? Icons.search_off : Icons.fitness_center,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isSearching
                              ? 'No studios found for "$_searchQuery"'
                              : 'No studios in ${userKotaValues.reverse[currentCity]}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _filteredStudios.length + (isSearching ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show search results header when searching
                      if (isSearching && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Found ${_filteredStudios.length} studio${_filteredStudios.length != 1 ? 's' : ''} for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }

                      final studioIndex = isSearching ? index - 1 : index;
                      return StudioCard(studio: _filteredStudios[studioIndex]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateStudio,
        backgroundColor: AppColors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
