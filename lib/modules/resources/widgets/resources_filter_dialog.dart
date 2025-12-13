// lib/modules/resources/widgets/resources_filter_dialog.dart
import 'package:flutter/material.dart';

class ResourcesFilterDialog extends StatefulWidget {
  const ResourcesFilterDialog({super.key});

  @override
  State<ResourcesFilterDialog> createState() => _ResourcesFilterDialogState();
}

class _ResourcesFilterDialogState extends State<ResourcesFilterDialog> {
  String selectedLevel = 'beginner'; // default bebas

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, -0.6),
      // biar muncul di tengah layar
      child: Hero(
        tag: 'resources-filter-hero',
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChip('Advanced', 'advanced', const Color(0xFFD191EF)),
                const SizedBox(width: 8),
                _buildChip('Beginner', 'beginner', const Color(0xFF84D000)),
                const SizedBox(width: 8),
                _buildChip('Intermediet', 'intermediate', const Color(0xFF8BC5FF)),
              ],
            ),
            )
            
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value, Color color) {
    final bool isSelected = selectedLevel == value;

    bool isPressed = false;

    return StatefulBuilder(
      builder: (_, setLocalState) {
        return GestureDetector(
          onTapDown: (_) => setLocalState(() => isPressed = true),
          onTapUp: (_) => setLocalState(() => isPressed = false),
          onTapCancel: () => setLocalState(() => isPressed = false),
          onTap: () {
            setState(() => selectedLevel = value);
            Navigator.of(context).pop(value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isPressed
                  ? color.withOpacity(0.55)  // ditekan → lebih pudar
                  : isSelected
                      ? color                  // dipilih → paling terang
                      : color.withOpacity(0.9), // default → terang
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
}
