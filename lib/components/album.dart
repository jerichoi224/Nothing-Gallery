import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/style.dart';

Widget albumWidget(Function onClick, String title, Uint8List thumbnailImage) {
  double radius = 8.0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Stack(
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
                onLongPress: (){
                  
                },
              ),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
        child: Text(
          title.toUpperCase(),
          style: albumTitleStyle(),
        ),
      ),
    ],
  );
}
