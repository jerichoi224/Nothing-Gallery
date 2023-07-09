import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../components/DoubleTappableInteractiveViewer.dart';

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
    return Scaffold(
        body: Stack(children: <Widget>[
      Center(
        child: CarouselSlider(
          disableGesture: true,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1,
            enableInfiniteScroll: false,
          ),
          items: [1, 2, 3, 4, 5].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return DoubleTappableInteractiveViewer(
                    scaleDuration: const Duration(milliseconds: 300),
                    child: AssetEntityImage(
                      widget.image,
                      isOriginal: true,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame == null) {
                          // fallback to placeholder
                          return Container(
                            color: Colors.white12,
                            height: widget.image.height.toDouble(),
                            width: widget.image.width.toDouble(),
                          );
                        }
                        return child;
                      },
                    ));
              },
            );
          }).toList(),
        ),
      )
    ]));
  }
}
