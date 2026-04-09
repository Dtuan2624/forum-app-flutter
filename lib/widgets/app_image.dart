import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    if (kIsWeb || imageUrl!.startsWith('http') || imageUrl!.startsWith('blob:')) {
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorWidget(),
      );
    }

    return Image.file(
      File(imageUrl!),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _errorWidget(),
    );
  }

  Widget _errorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
