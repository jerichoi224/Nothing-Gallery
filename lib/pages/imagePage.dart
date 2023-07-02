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
  File? imageFile;
  @override
  void initState() {
    super.initState();
    getImage();
  }

  Future<void> getImage() async {
    File? file = await widget.image.file;
    if (file != null) {
      setState(() {
        imageFile = file;
      });
    }
  }

  Widget imageView() {
    if (imageFile == null) return Container();
    return Expanded(child: Image.file(imageFile!));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [imageView()])));
  }
}
