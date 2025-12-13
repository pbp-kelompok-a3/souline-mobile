import 'package:flutter/material.dart';
import 'package:youtube_player_embed/youtube_player_embed.dart';
import 'package:souline_mobile/modules/resources/widgets/level_badge.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/resources_entry.dart';
import 'package:flutter/foundation.dart';


class ResourceDetailPage extends StatefulWidget {
  final ResourcesEntry resource;
  final List<ResourcesEntry> otherResources;

  const ResourceDetailPage({
    super.key,
    required this.resource,
    this.otherResources = const [],
  });

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    final sameLevelOthers = widget.otherResources
        .where((r) => r.id != resource.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, // pas di-scroll, header tetap nempel di atas
            floating: false,
            expandedHeight: 120,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7EB3DE), Color(0xFF446178)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    // atur jarak kiri-kanan & bawah judul
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // BACK ARROW
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),

                        const Spacer(),

                        const Text(
                          'Resources',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LevelBadge(
                        level: resource.level,
                        fontSize: 13,
                        horizontalPadding: 14,
                        verticalPadding: 6,
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: handle bookmark
                        },
                        icon: const Icon(
                          Icons.bookmark_border_rounded,
                          color: AppColors.darkBlue,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                 // YOUTUBE VIDEO
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: kIsWeb
                        ? Container(
                            height: 200,
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Text(
                              'Video playback not supported on Web',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : YoutubePlayerEmbed(
                            key: ValueKey(resource.videoId),
                            videoId: resource.videoId,
                            aspectRatio: 16 / 9,
                            autoPlay: false,
                            mute: false,
                            enabledShareButton: false,
                            hidenChannelImage: true,
                            hidenVideoControls: false,
                          ),
                  ),

                  const SizedBox(height: 20),

                  // TITLE
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Text(
                    resource.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // SECTION: ANOTHER EXERCISE
                  if (sameLevelOthers.isNotEmpty) ...[
                    const Text(
                      'Another Exercise',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: sameLevelOthers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final other = sameLevelOthers[index];
                          return _MiniResourceCard(
                            resource: other,
                            onTap: () {
                              // push ke detail lain
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResourceDetailPage(
                                    resource: other,
                                    otherResources: widget.otherResources,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// MINI CARD UNTUK "ANOTHER EXERCISE"
class _MiniResourceCard extends StatelessWidget {
  final ResourcesEntry resource;
  final VoidCallback? onTap;

  const _MiniResourceCard({
    required this.resource,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THUMBNAIL + PLAY + LEVEL BADGE (pojok kanan atas)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Image.network(
                    resource.thumbnailUrl,
                    width: 260,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: LevelBadge(
                      level: resource.level,
                      fontSize: 10,
                      horizontalPadding: 10,
                      verticalPadding: 4,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    maxLines: 1,
                    resource.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



