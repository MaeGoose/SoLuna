import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A favorites button plus a row of small overlapping avatar circles.
/// Takes initials instead of real photo URLs for now, since there are no
/// real user photos yet — swap for CircleAvatar(backgroundImage:...) once
/// there are.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.avatarLabels,
    required this.onFavoriteTap,
  });

  final List<String> avatarLabels;
  final VoidCallback onFavoriteTap;

  static const _colors = [AppColors.primary, AppColors.secondary];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onFavoriteTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.bgBlush,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: AppColors.secondary, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        for (var i = 0; i < avatarLabels.length; i++)
          Transform.translate(
            offset: Offset(i == 0 ? 0 : -10, 0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.surface, width: 2),
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _colors[i % _colors.length],
                child: Text(
                  avatarLabels[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
