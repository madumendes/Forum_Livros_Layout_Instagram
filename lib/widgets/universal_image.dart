import 'dart:convert';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    // Se for URL da internet (Ana Leitora)
    if (imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    // Se for Base64 (Suas fotos)
    try {
      return Image.memory(
        base64Decode(imageUrl!),
        height: height,
        width: width,
        fit: fit,
      );
    } catch (e) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: const Icon(Icons.error),
      );
    }
  }
}
