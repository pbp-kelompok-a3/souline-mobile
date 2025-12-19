import 'package:flutter/material.dart';
import 'package:souline_mobile/shared/models/resources_entry.dart';

class ResourcesCard extends StatelessWidget {
  final ResourcesEntry resource;
  final VoidCallback? onTapDetail;
  final VoidCallback? onTapBookmark;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;


  const ResourcesCard({
    super.key,
    required this.resource,
    this.onTapDetail,
    this.onTapBookmark,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [ /* kalau ada */ ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HANYA THUMBNAIL YANG BISA DI TAP ===
          GestureDetector(
            onTap: onTapDetail,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  Image.network(
                    resource.thumbnailUrl,
                    width: double.infinity,
                    height: 155,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if(showAdminActions)
                  Positioned(                     
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        _AdminPillButton(
                          label: "Edit",
                          color: Colors.blue,
                          icon: Icons.edit,
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _AdminPillButton(
                          label: "Delete",
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // BAGIAN PUTIH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE + BOOKMARK
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TITLE (TIDAK DIBUNGKUS GESTUREDETECTOR)
                    SizedBox(
                      width: 200, // supaya nggak nabrak icon
                      child: Text(
                        resource.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF233654),
                        ),
                      ),
                    ),

                    // BOOKMARK (BISA DI TAP)
                    GestureDetector(
                      onTap: onTapBookmark,
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        color: Color(0xFF233654),
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ROW: description + "Detail"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // DESCRIPTION (TIDAK BISA DI TAP)
                    Expanded(
                      child: Text(
                        resource.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A7C89),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // === HANYA "DETAIL" YANG BISA DI TAP ===
                    GestureDetector(
                      onTap: onTapDetail,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Detail",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF9A14A),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_outward,
                            size: 10,
                            color: Color(0xFFF9A14A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AdminPillButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _AdminPillButton({
    required this.label,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
