import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget(
      {super.key,
      required this.asset,
      required this.radius,
      required this.isOriginal});

  final double radius;
  final AssetEntity asset;
  final bool isOriginal;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: AssetEntityImage(
              asset,
              isOriginal: isOriginal,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame == null) {
                  // fallback to placeholder
                  return Container(
                    color: Colors.white12,
                  );
                }
                return child;
              },
            )));
  }
}
