import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagePageWidget extends StatefulWidget {
  final AssetEntity image;

  const ImagePageWidget({super.key, required this.image});

  @override
  State createState() => _ImagePageWidgetState();
}

class _ImagePageWidgetState extends State<ImagePageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: Stack(children: <Widget>[
          InteractiveViewer(
            maxScale: 5,
            child: Center(
                child: Image(
                    image: AssetEntityImageProvider(
              widget.image,
              isOriginal: true,
            ))),
          )
        ])));
  }
}
