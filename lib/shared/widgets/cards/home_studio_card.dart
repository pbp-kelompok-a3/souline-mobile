import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/studio_entry.dart';
import '../../../modules/studio/studio_service.dart';

class HomeStudioCard extends StatelessWidget {
  final Studio studio;
  final VoidCallback? onTap;

  const HomeStudioCard({super.key, required this.studio, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Studio thumbnail image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                proxiedImageUrl(studio.thumbnail),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.teal.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: AppColors.darkBlue,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.cream,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.teal,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Studio info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studio.namaStudio,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studio.area,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
