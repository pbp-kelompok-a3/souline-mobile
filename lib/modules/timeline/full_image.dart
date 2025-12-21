import 'package:flutter/material.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,

      body: InteractiveViewer(
        panEnabled: true, 
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
        ),
      ),
    );
  }
}