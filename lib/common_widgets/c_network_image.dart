import 'package:flutter/material.dart';

class CNetworkImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit fit;
  const CNetworkImage(this.url, {super.key, this.width, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(url, width: width, height: height, fit: fit,
        loadingBuilder: (c, ch, progress) =>
        progress == null ? ch : const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
      ),
    );
  }
}
