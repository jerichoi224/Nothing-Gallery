import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

Widget imageWidget(Function onClick, AssetEntity image) {
  double radius = 0;
  return Stack(
    children: <Widget>[
      imageThumbnailWidget(image, radius),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(radius))),
            onTap: () {
              onClick();
            },
            onLongPress: () {},
          ),
        ),
      ),
    ],
  );
}

Widget imageThumbnailWidget(AssetEntity image, double radius) {
  return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AssetEntityImage(
            image,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(200),
            thumbnailFormat: ThumbnailFormat.jpeg,
            fit: BoxFit.cover,
          )));
}
