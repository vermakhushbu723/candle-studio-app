import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/user.dart';

/// Profile photo (Google) or initials; a person icon when logged out.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 40});
  final AppUser? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final u = user;
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: u == null ? AppColors.sand : AppColors.terracotta,
      child: u == null
          ? Icon(Icons.person_outline_rounded, color: AppColors.terracotta, size: size * 0.55)
          : Text(
              initials(u.name),
              style: AppText.sans(size: size * 0.36, weight: FontWeight.w700, color: Colors.white),
            ),
    );
    if (u?.avatar == null) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: u!.avatar!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => fallback,
        placeholder: (_, _) => fallback,
      ),
    );
  }
}
