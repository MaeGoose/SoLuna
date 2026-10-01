import 'package:flutter/material.dart';

import '../models/memory.dart';
import 'memory_photo.dart';

/// A square gallery thumbnail for one memory, with a small heart badge
/// when favorited. Used in folder galleries and search results — both
/// are just "a grid of memories," so they share this instead of each
/// keeping their own copy.
class MemoryThumbnail extends StatelessWidget {
  const MemoryThumbnail({super.key, required this.memory, required this.onTap});

  final Memory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: MemoryPhoto(
              mediaUrl: memory.mediaUrl,
              localBytes: memory.localBytes,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (memory.isFavorite)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.favorite, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}
