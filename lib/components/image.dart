import 'dart:typed_data';

import 'package:flutter/material.dart';

Widget imageWidget(Function onClick, Uint8List thumbnailImage) {
  double radius = 0;
  return Stack(
    children: <Widget>[
      imageThumbnailWidget(thumbnailImage, radius),
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

Widget imageThumbnailWidget(Uint8List thumbnailImage, double radius) {
  return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(
          thumbnailImage,
          fit: BoxFit.cover,
        ),
      ));
}
