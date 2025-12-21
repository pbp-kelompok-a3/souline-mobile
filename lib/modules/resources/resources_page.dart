import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:souline_mobile/shared/widgets/app_header.dart';
import 'package:souline_mobile/shared/models/resources_entry.dart';
import 'package:souline_mobile/modules/resources/widgets/resources_card.dart';
import 'package:souline_mobile/modules/resources/HeroDialogRoute.dart';
import 'package:souline_mobile/modules/resources/widgets/resources_filter_dialog.dart';
import 'package:souline_mobile/modules/resources/resources_detail_page.dart';
import 'package:souline_mobile/modules/resources/widgets/level_badge.dart';
import 'package:souline_mobile/shared/widgets/left_drawer.dart';
import 'package:souline_mobile/shared/widgets/navigation_bar.dart';
import 'package:souline_mobile/modules/resources/resources_form_page.dart';
import 'package:souline_mobile/modules/user/bookmarks_service.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  String? _selectedLevel; // null = mode default (section view)
  String _searchQuery = '';
  bool _isAdmin = false;
  CookieRequest? _lastRequest;
  bool _initializedRequest = false;
  bool _requestedAdminStatus = false;

  // biar FutureBuilder nggak refetch terus setiap build()
  late Future<List<ResourcesEntry>> _futureResources;

  @override
  void initState() {
    super.initState();

    // NOTE: CookieRequest belum tersedia di initState lewat context.watch,
    // jadi kita set future ini di didChangeDependencies.
    _futureResources = Future.value([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final request = context.watch<CookieRequest>();
    if (!_initializedRequest || _lastRequest != request) {
      _initializedRequest = true;
      _lastRequest = request;
      _futureResources = fetchResources(request);
      _requestedAdminStatus = false;
    }

    if (!_requestedAdminStatus) {
      _requestedAdminStatus = true;
      _loadAdminStatus(request);
    }
  }

  String _joinBase(String path) {
    final base = AppConstants.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  Future<List<ResourcesEntry>> fetchResources(CookieRequest request) async {
    final candidates = [
      'resources/api/list/',
      'resources/api/',
      'api/resources/',
      'resources/json/',
    ];
    dynamic payload;
    Exception? lastError;
    for (final path in candidates) {
      final url = _joinBase(path);
      try {
        final data = await request.get(url);
        if (data is List) {
          payload = data;
          break;
        }
        if (data is Map && data['results'] is List) {
          payload = data['results'];
          break;
        }
        lastError = Exception('Unexpected response format from $url');
      } catch (e) {
        lastError = Exception('Failed to load $url: $e');
      }
    }

    if (payload == null) {
      throw lastError ?? Exception('Unable to fetch resources');
    }

    final List<ResourcesEntry> result = [];
    for (final item in payload) {
      if (item is Map<String, dynamic>) {
        result.add(ResourcesEntry.fromJson(item));
      }
    }
    return result;
  }

  Future<void> _refresh() async {
    final request = _lastRequest ?? context.read<CookieRequest>();
    setState(() {
      _futureResources = fetchResources(request);
    });
  }

  Future<void> _loadAdminStatus(CookieRequest request) async {
    if (!request.loggedIn) {
      if (mounted && _isAdmin) setState(() => _isAdmin = false);
      return;
    }
    try {
      final data = await request.get(_joinBase('is-admin/'));
      final admin = data is Map<String, dynamic> && data['is_admin'] == true;
      if (mounted) setState(() => _isAdmin = admin);
    } catch (_) {
      if (mounted) setState(() => _isAdmin = false);
    }
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
        return const Color(0xFFE5FBC3); // hijau muda
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EA),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: FutureBuilder<List<ResourcesEntry>>(
          future: _futureResources,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Failed to load resources.",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final allBase = snapshot.data ?? [];

            // search filter
            final all = allBase.where((r) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return r.title.toLowerCase().contains(q) ||
                  r.description.toLowerCase().contains(q) ||
                  r.level.toLowerCase().contains(q);
            }).toList();

            final beginner =
                all.where((r) => r.level.toLowerCase() == 'beginner').toList();
            final intermediate = all
                .where((r) => r.level.toLowerCase() == 'intermediate')
                .toList();
            final advanced =
                all.where((r) => r.level.toLowerCase() == 'advanced').toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 190),
                    child: _selectedLevel == null
                        ? _buildSectionView(beginner, intermediate, advanced)
                        : _buildFilteredVerticalView(all),
                  ),

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
                    showDrawerButton: true,
                  ),

                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: FloatingNavigationBar(currentIndex: 2),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _isAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF62C4D9),
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 32, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResourceFormPage(),
                    ),
                  );
                  // setelah balik dari form, refresh list
                  _refresh();
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
    List<ResourcesEntry> advanced,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (beginner.isNotEmpty)
            _ResourcesSection(
              label: 'Beginner',
              resources: beginner,
              isAdmin: _isAdmin,
              onEdit: (r) async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResourceFormPage(initialResource: r),
                  ),
                );
                if (result == true) _refresh();
              },
              onDelete: _confirmDelete,
              onBookmark: _toggleBookmark,
            ),
          if (intermediate.isNotEmpty)
            _ResourcesSection(
              label: 'Intermediate',
              resources: intermediate,
              isAdmin: _isAdmin,
              onEdit: (r) async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResourceFormPage(initialResource: r),
                  ),
                );
                if (result == true) _refresh();
              },
              onDelete: _confirmDelete,
              onBookmark: _toggleBookmark,
            ),
          if (advanced.isNotEmpty)
            _ResourcesSection(
              label: 'Advanced',
              resources: advanced,
              isAdmin: _isAdmin,
              onEdit: (r) async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResourceFormPage(initialResource: r),
                  ),
                );
                if (result == true) _refresh();
              },
              onDelete: _confirmDelete,
              onBookmark: _toggleBookmark,
            ),
          if (beginner.isEmpty && intermediate.isEmpty && advanced.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("No resources found.")),
            ),
        ],
      ),
    );
  }

  // MODE 2: Vertical List After Filtering
  Widget _buildFilteredVerticalView(List<ResourcesEntry> all) {
    final filtered =
        all.where((r) => r.level.toLowerCase() == _selectedLevel).toList();

    final primaryColor = _primaryColorForLevel(_selectedLevel);
    final bgColor = _backgroundColorForLevel(_selectedLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          ...filtered.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: ResourcesCard(
                resource: r,
                showAdminActions: _isAdmin,
                onEdit: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResourceFormPage(initialResource: r),
                    ),
                  );
                  if (result == true) _refresh();
                },
                onDelete: () => _confirmDelete(r),
                onTapBookmark: () => _toggleBookmark(r),
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
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text("No resources for this level.")),
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
            onPressed: () async {
              Navigator.pop(context);
              await _deleteResource(r);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteResource(ResourcesEntry resource) async {
    final request = _lastRequest ?? context.read<CookieRequest>();

    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin account required to delete')),
      );
      return;
    }

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to delete resources')),
      );
      return;
    }

    final url = _joinBase('resources/api/delete/${resource.id}/');
    try {
      final response = await request.postJson(url, jsonEncode({}));
      final success = response is Map<String, dynamic> &&
          (response['status'] == 'deleted' || response['status'] == 'success');

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource deleted')),
        );
        _refresh();
      } else {
        final reason = response is Map<String, dynamic> && response['status'] != null
            ? response['status'].toString()
            : 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $reason')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> _toggleBookmark(ResourcesEntry resource) async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add a bookmark'),
          backgroundColor: AppColors.darkBlue,
        ),
      );
      return;
    }

    final service = BookmarksService(request);
    final newState = await service.toggleBookmark(
      appLabel: BookmarkAppLabel.resources,
      model: BookmarkContentType.resource,
      objectId: resource.id.toString(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Resource bookmarked' : 'Bookmark removed'),
          backgroundColor: AppColors.darkBlue,
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
  final Function(ResourcesEntry)? onBookmark;

  const _ResourcesSection({
    required this.label,
    required this.resources,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
    this.onBookmark,
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
                    onTapBookmark: () => onBookmark?.call(r),
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
