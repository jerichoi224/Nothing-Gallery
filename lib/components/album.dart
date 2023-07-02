import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';

Widget albumWidget(Function onClick, String title, Uint8List thumbnailImage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
              thumbnailImage,
              fit: BoxFit.cover,
            ),
          )),
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
