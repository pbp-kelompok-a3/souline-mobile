import 'package:flutter/material.dart';
import '../../../shared/models/event_model.dart';
import '../../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import '../../studio/studio_page.dart'; 

class EventCard extends StatelessWidget {
  final EventModel event;
  final String posterUrl;
  final VoidCallback onDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;

  const EventCard({
    super.key,
    required this.event,
    required this.posterUrl,
    required this.onDetail,
    this.onEdit,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0ECE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          // Left image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: posterUrl.isNotEmpty
                ? Image.network(
                    posterUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[100],
                    child: const Center(
                      child: Text(
                        'No Image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ),

          // Right content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF2E4057),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat("dd MMMM yyyy", "en_US").format(event.date),
                    style: const TextStyle(color: Color(0xFF7A8D9C), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Location link
                  if (event.location.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudioPage()),
                        );
                      },
                      child: Text(
                        event.location ?? 'Location',
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF445566)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onDetail,
                        child: const Text(
                          'Detail',
                          style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isOwner) const SizedBox(width: 8),
                      if (isOwner && onEdit != null)
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Edit',
                        ),
                      if (isOwner && onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
