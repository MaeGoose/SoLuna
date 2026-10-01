import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows a memory's photo — local bytes picked this session take priority
/// (nothing's been uploaded yet), then a real remote URL, then falls back
/// to the same gradient placeholder used before real photos existed.
/// Centralizing this in one place means every screen automatically starts
/// showing real photos the moment either is set — nothing else has to
/// change.
class MemoryPhoto extends StatelessWidget {
  const MemoryPhoto({
    super.key,
    this.mediaUrl,
    this.localBytes,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? mediaUrl;
  final Uint8List? localBytes;
  final BorderRadius? borderRadius;

  /// BoxFit.cover (the default) crops to fill — right for fixed-size
  /// thumbnails (grid cells, cards, polaroids). Pass BoxFit.contain
  /// wherever the whole photo actually needs to be visible, like the
  /// full-size preview screen.
  final BoxFit fit;

  static const _placeholder = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.secondary, AppColors.bgPeach],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final bytes = localBytes;
    final url = mediaUrl;

    if (bytes != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.memory(bytes, fit: fit),
      );
    }

    if (url == null || url.isEmpty) {
      return ClipRRect(borderRadius: radius, child: _placeholder);
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url,
        fit: fit,
        // Falls back to the same placeholder if the URL 404s or is
        // unreachable, instead of showing Flutter's default broken-image
        // icon.
        errorBuilder: (context, error, stackTrace) => _placeholder,
      ),
    );
  }
}
