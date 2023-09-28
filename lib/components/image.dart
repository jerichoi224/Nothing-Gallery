
import 'package:flutter/material.dart';
import 'package:nothing_gallery/constants/imageWidgetStatus.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

Widget imageWidget(Function onClick, AssetEntity image,
    ImageWidgetStatus status, Function(String imageId) onLongTap) {
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
              color: status == ImageWidgetStatus.selected
                  ? Colors.black38
                  : Colors.transparent,
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(radius))),
                onTap: () {
                  onClick();
                },
                onLongPress: () {
                  onLongTap(image.id);
                },
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
              : Container(),
          status == ImageWidgetStatus.normal
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      status == ImageWidgetStatus.selected
                          ? Icons.check_circle_outline
                          : Icons.circle_outlined,
                      size: 22,
                      color: status == ImageWidgetStatus.selected
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ],
                )
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
