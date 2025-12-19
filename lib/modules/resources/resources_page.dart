import 'package:flutter/material.dart';
import 'package:souline_mobile/shared/widgets/app_header.dart';
import 'package:souline_mobile/shared/models/resources_entry.dart';
import 'package:souline_mobile/modules/resources/widgets/resources_card.dart';
import 'package:souline_mobile/modules/resources/HeroDialogRoute.dart';
import 'package:souline_mobile/modules/resources/widgets/resources_filter_dialog.dart';
import 'package:souline_mobile/modules/resources/resources_detail_page.dart';
import 'package:souline_mobile/modules/resources/widgets/level_badge.dart';
import 'package:souline_mobile/shared/widgets/navigation_bar.dart';
import 'package:souline_mobile/modules/resources/resources_form_page.dart';


class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  String? _selectedLevel; // null = mode default (section view)
  String _searchQuery = '';
  bool isAdmin = true; 

  late List<ResourcesEntry> dummyResources;

  @override
  void initState() {
    super.initState();
    dummyResources = [
      ResourcesEntry(
        id: 1,
        title: '30 MIN PILATES',
        description:
            'This beginner-to-moderate level Pilates class is perfect...',
        youtubeUrl: 'https://www.youtube.com/embed/wtVyZmHnlxM',
        videoId: 'wtVyZmHnlxM',
        thumbnailUrl:
            'https://img.youtube.com/vi/wtVyZmHnlxM/hqdefault.jpg',
        level: 'beginner',
      ),
      ResourcesEntry(
        id: 2,
        title: '30 MIN FULL BODY',
        description: 'Intermediate full body pilates...',
        youtubeUrl: 'https://www.youtube.com/embed/C2HX2pNbUCM',
        videoId: 'C2HX2pNbUCM',
        thumbnailUrl:
            'https://img.youtube.com/vi/C2HX2pNbUCM/hqdefault.jpg',
        level: 'intermediate',
      ),
      ResourcesEntry(
        id: 3,
        title:
            'LATIHAN PILATES SELURUH TUBUH 20 MENIT - Rutinitas Inti di Rumah',
        description: 'Beginner pilates session...',
        youtubeUrl: 'https://www.youtube.com/embed/sPNpgaXVGw4',
        videoId: 'sPNpgaXVGw4',
        thumbnailUrl:
            'https://img.youtube.com/vi/sPNpgaXVGw4/hqdefault.jpg',
        level: 'beginner',
      ),
      ResourcesEntry(
        id: 4,
        title:
            'LATIHAN PILATES SELURUH TUBUH 20 MENIT - Rutinitas Inti di Rumah',
        description: 'Advanced pilates session...',
        youtubeUrl: 'https://www.youtube.com/embed/sPNpgaXVGw4',
        videoId: 'sPNpgaXVGw4',
        thumbnailUrl:
            'https://img.youtube.com/vi/sPNpgaXVGw4/hqdefault.jpg',
        level: 'advanced',
      ),
    ];
  }

  Color _primaryColorForLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'advanced':
        return const Color(0xFFC58CFF); // ungu
      case 'intermediate':
        return const Color(0xFF8BC5FF); // biru muda
      case 'beginner':
      default:
        return const Color(0xFF84D000); // hijau
    }
  }

  Color _backgroundColorForLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'advanced':
        return const Color(0xFFF3DDFF); // ungu muda
      case 'intermediate':
        return const Color(0xFFE1F1FF); // biru muda banget
      case 'beginner':
      default:
        return const Color(0xFFE5FBC3); // hijau muda (kayak desain kamu)
    }
  }

  // sementara dummy data
  // List<ResourcesEntry> get dummyResources => [ ... ]; // removed getter
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final allBase = dummyResources;
    final all = allBase.where((r) {
      if (_searchQuery.isEmpty) return true;

      final q = _searchQuery.toLowerCase();
      return r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.level.toLowerCase().contains(q);
    }).toList();

    final beginner =
        all.where((r) => r.level.toLowerCase() == 'beginner').toList();
    final intermediate =
        all.where((r) => r.level.toLowerCase() == 'intermediate').toList();
    final advanced =
        all.where((r) => r.level.toLowerCase() == 'advanced').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EA),
      body: SafeArea(
        child: Stack(
          children: [
            // === KONTEN UTAMA DI BELAKANG (LIST / SCROLL) ===
            Padding(
              // angka 190 bisa kamu tweak (180–200) sampai pas
              padding: const EdgeInsets.only(top: 190),
              child: _selectedLevel == null
                  ? _buildSectionView(beginner, intermediate, advanced)
                  : _buildFilteredVerticalView(all),
            ),

          // === HEADER DI ATAS SEMUA ===
          AppHeader(
            title: 'Resources',
            onSearchChanged: _onSearch,
            filterHeroTag: 'resources-filter-hero',
            filterButton: GestureDetector(
              onTap: () async {
                final level = await Navigator.of(context).push<String>(
                  HeroDialogRoute(
                    builder: (_) => const ResourcesFilterDialog(),
                  ),
                );

                if (level != null) {
                  setState(() => _selectedLevel = level);
                }
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC5FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            ),
          ),    

          const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavigationBar(
                currentIndex: 2,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
      ?Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF62C4D9),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ResourceFormPage(),// TODO: bikin halaman ini
              ),
            );
          },
        ),
      ) 
      : null,


    );
  }


  // MODE 1: Section Horizontal Scroll
  Widget _buildSectionView(
      List<ResourcesEntry> beginner,
      List<ResourcesEntry> intermediate,
      List<ResourcesEntry> advanced) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (beginner.isNotEmpty)
            _ResourcesSection(
              label: 'Beginner', 
              resources: beginner,
              isAdmin: isAdmin,
              onEdit: (r) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Center(child: Text('Form di sini'))),
                  ),
                );
              },
              onDelete: _confirmDelete,
            ),
          if (intermediate.isNotEmpty)
            _ResourcesSection(
              label: 'Intermediate', 
              resources: intermediate,
              isAdmin: isAdmin,
              onEdit: (r) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Center(child: Text('Form di sini'))),
                  ),
                );
              },
              onDelete: _confirmDelete,
            ),
          if (advanced.isNotEmpty)
            _ResourcesSection(
              label: 'Advanced', 
              resources: advanced,
              isAdmin: isAdmin,
              onEdit: (r) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Center(child: Text('Form di sini'))),
                  ),
                );
              },
              onDelete: _confirmDelete,
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // MODE 2: Vertical List After Filtering
  Widget _buildFilteredVerticalView(List<ResourcesEntry> all) {
    final filtered = all
        .where((r) => r.level.toLowerCase() == _selectedLevel)
        .toList();

    // warna label disesuaikan dengan level
    final primaryColor = _primaryColorForLevel(_selectedLevel);
    final bgColor = _backgroundColorForLevel(_selectedLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LABEL BESAR (Beginner / Intermediate / Advanced)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (_selectedLevel ?? '').toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // LIST VERTICAL CARD
          ...filtered.map(
            (r) => Padding(
              // biar tiap card punya jarak ke card lain
              padding: const EdgeInsets.only(bottom: 18),
              child: ResourcesCard(
                resource: r,
                showAdminActions: isAdmin, 
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(body: Center(child: Text('Form di sini'))),
                    ),
                  );
                },
                onDelete:(){
                  _confirmDelete(r);
                },
                onTapDetail: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResourceDetailPage(
                        resource: r,
                        otherResources: filtered,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _confirmDelete(ResourcesEntry r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Resource?"),
        content: Text("Are you sure you want to delete '${r.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // TODO: panggil API delete di sini
              Navigator.pop(context);

              setState(() {
                // sementara: hapus dari dummy list
                dummyResources.removeWhere((item) => item.id == r.id);
              });
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

}

// ===================================================================
//  WIDGET SECTION HORIZONTAL
// ===================================================================

class _ResourcesSection extends StatelessWidget {
  final String label;
  final List<ResourcesEntry> resources;
  final bool isAdmin;
  final Function(ResourcesEntry)? onEdit;
  final Function(ResourcesEntry)? onDelete;

  const _ResourcesSection({
    required this.label,
    required this.resources,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LevelBadge(
            level: label.toLowerCase(),
            fontSize: 12,
            horizontalPadding: 14,
            verticalPadding: 4,
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: resources.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final r = resources[index];

                return SizedBox(
                  width: 276,
                  child: ResourcesCard(
                    resource: r,
                    showAdminActions: isAdmin,
                    onEdit: () => onEdit?.call(r),
                    onDelete: () => onDelete?.call(r),
                    onTapDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResourceDetailPage(
                            resource: r,
                            otherResources: resources,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
