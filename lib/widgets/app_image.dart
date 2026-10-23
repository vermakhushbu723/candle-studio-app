import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';

/// Network photo from the website (cached), with a shimmer while loading and a candle icon on error.
class AppImage extends StatelessWidget {
  const AppImage(this.path, {super.key, this.fit = BoxFit.cover, this.tone, this.radius = 0, this.width, this.height});

  final String? path;
  final BoxFit fit;
  final String? tone;
  final double radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.parse(tone);
    final url = imageUrl(path);
    final placeholder = Container(
      width: width,
      height: height,
      color: bg,
      alignment: Alignment.center,
      child: const Icon(Icons.local_fire_department_outlined, color: AppColors.caramel, size: 32),
    );
    final image = url.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            width: width,
            height: height,
            fadeInDuration: const Duration(milliseconds: 250),
            placeholder: (_, _) => Shimmer.fromColors(
              baseColor: bg,
              highlightColor: AppColors.cream,
              child: Container(width: width, height: height, color: bg),
            ),
            errorWidget: (_, _, _) => placeholder,
          );
    return radius == 0 ? image : ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}
