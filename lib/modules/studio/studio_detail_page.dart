import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/studio_entry.dart';
import '../../shared/models/event_model.dart';
import '../../shared/widgets/navigation_bar.dart';
import '../../shared/widgets/cards/home_event_card.dart';
import '../events/events_service.dart';
import '../events/events_detail.dart';
import 'studio_form_page.dart';
import 'studio_service.dart';

class StudioDetailPage extends StatefulWidget {
  final Studio studio;
  final bool isAdmin;
  final Future<void> Function()? onRefresh;

  const StudioDetailPage({
    super.key,
    required this.studio,
    required this.isAdmin,
    this.onRefresh,
  });

  @override
  State<StudioDetailPage> createState() => _StudioDetailPageState();
}

class _StudioDetailPageState extends State<StudioDetailPage> {
  late Studio _studio;
  Future<List<EventModel>>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _studio = widget.studio;
    _eventsFuture = _fetchStudioEvents();
  }

  Future<List<EventModel>> _fetchStudioEvents() async {
    final request = context.read<CookieRequest>();
    // Fetch all events for now as per instructions (client-side filtering)
    final service = EventService(request, AppConstants.baseUrl);
    try {
      final allEvents = await service.fetchEvents();
      // Filter events where location_id matches this studio's ID
      final studioEvents = allEvents.where((e) {
        return e.locationId == _studio.id;
      }).toList();
      return studioEvents;
    } catch (e) {
      debugPrint('Error fetching studio events: $e');
      return [];
    }
  }

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse(_studio.gmapsLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callStudio() async {
    final Uri url = Uri.parse('tel:${_studio.nomorTelepon}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudioFormPage(studio: _studio)),
    ).then((value) {
      if (value is Studio) {
        setState(() => _studio = value);
        if (widget.onRefresh != null) widget.onRefresh!();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Studio updated'),
            backgroundColor: AppColors.darkBlue,
          ),
        );
        return;
      }
      if (value == true && widget.onRefresh != null) widget.onRefresh!();
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Studio'),
          content: Text(
            'Are you sure you want to delete "${_studio.namaStudio}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _deleteStudio(context),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStudio(BuildContext context) async {
    Navigator.of(context).pop();

    final scaffold = ScaffoldMessenger.of(context);
    try {
      final request = context.read<CookieRequest>();
      final service = StudioService(request);
      await service.deleteStudio(_studio.id);

      if (widget.onRefresh != null) await widget.onRefresh!();

      Navigator.of(context).pop();
      scaffold.showSnackBar(
        SnackBar(
          content: Text('${_studio.namaStudio} deleted successfully.'),
          backgroundColor: AppColors.darkBlue,
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App bar with studio image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.darkBlue,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _studio.namaStudio,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        proxiedImageUrl(_studio.thumbnail),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.teal.withOpacity(0.3),
                            child: const Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: AppColors.darkBlue,
                            ),
                          );
                        },
                      ),

                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: widget.isAdmin
                    ? [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _navigateToEdit(context),
                          tooltip: 'Edit Studio',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _showDeleteConfirmation(context),
                          tooltip: 'Delete Studio',
                        ),
                      ]
                    : null,
              ),

              // Studio details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating section
                      _buildRatingCard(),
                      const SizedBox(height: 16),

                      // Location section
                      _buildSectionCard(
                        icon: Icons.location_on,
                        title: 'Location',
                        children: [
                          _buildInfoRow(
                            'City',
                            userKotaValues.reverse[_studio.kota] ?? '',
                          ),
                          _buildInfoRow('Area', _studio.area),
                          _buildInfoRow('Address', _studio.alamat),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Contact section
                      _buildSectionCard(
                        icon: Icons.contact_phone,
                        title: 'Contact',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoRow(
                                  'Phone',
                                  _studio.nomorTelepon,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.phone,
                                  color: AppColors.teal,
                                ),
                                onPressed: _callStudio,
                                tooltip: 'Call Studio',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Maps button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.map),
                          label: const Text('Open in Google Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Events section (placeholder)
                      _buildEventsSection(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 85), // Spacer for navbar
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkBlue, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: AppColors.orange, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rating',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _studio.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/ 5.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // Star rating display
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                // Round rating to nearest 0.5 for star display
                final roundedRating = (_studio.rating * 2).round() / 2;
                if (roundedRating >= starValue) {
                  return const Icon(
                    Icons.star,
                    size: 24,
                    color: AppColors.orange,
                  );
                } else if (roundedRating >= starValue - 0.5) {
                  return const Icon(
                    Icons.star_half,
                    size: 24,
                    color: AppColors.orange,
                  );
                } else {
                  return Icon(
                    Icons.star_border,
                    size: 24,
                    color: AppColors.orange.withOpacity(0.5),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppColors.darkBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event, color: AppColors.darkBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              'Events in ${_studio.namaStudio}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        FutureBuilder<List<EventModel>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Error loading events: ${snapshot.error}'),
              );
            }

            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: AppColors.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No events scheduled',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check back later for upcoming events',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return HomeEventCard(
                    event: event,
                    posterUrl: event.poster,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailPage(
                            event: event,
                            baseUrl: AppConstants.baseUrl,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
