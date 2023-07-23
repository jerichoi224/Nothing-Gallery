import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

Widget imageWidget(Function onClick, AssetEntity image) {
  double radius = 0;

  String duration = '';

  if (image.type == AssetType.video) {
    duration = image.videoDuration.toString().split('.').first.padLeft(8, "0");
    if (duration.startsWith('00:')) {
      duration = duration.substring(3);
    }
  }
  return Hero(
      tag: image.id,
      child: Stack(
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
          image.type == AssetType.video
              ? Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(2, 2, 0, 0),
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 22,
                      ),
                    ),
                    Text(" $duration", style: videoDurationTextStyle())
                  ],
                )
              : Container()
        ],
      ));
}

Widget imageThumbnailWidget(AssetEntity image, double radius) {
  return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AssetEntityImage(
            image,
            isOriginal: false,
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
