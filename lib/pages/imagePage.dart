// ignore: file_names
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view_gallery.dart';

// ignore: must_be_immutable
class ImagePageWidget extends StatefulWidget {
  int index;
  int imageTotal;
  Uint8List thumbnail;
  final PageController pageController;
  List<AssetEntity> images;

  ImagePageWidget(
      {super.key,
      required this.images,
      required this.imageTotal,
      required this.thumbnail,
      required this.index})
      : pageController = PageController(initialPage: index);

  @override
  State createState() => _ImagePageWidgetState();
}

class _ImagePageWidgetState extends State<ImagePageWidget>
    with SingleTickerProviderStateMixin {
  int index = 0;
  List<AssetEntity> images = [];
  bool decorationVisible = true;

  late AnimationController animationController;
  late Animation fadeAnimation;

  @override
  void initState() {
    super.initState();
    index = widget.index;
    images = widget.images;
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    fadeAnimation = Tween(begin: 0, end: 1).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    Size orientatedSize = images[index].orientatedSize;

    return PhotoViewGalleryPageOptions(
        minScale: min(MediaQuery.of(context).size.width / orientatedSize.width,
            MediaQuery.of(context).size.height / orientatedSize.height),
        imageProvider: AssetEntityImage(
          images[index],
          isOriginal: true,
        ).image

        //  AssetEntityImageProvider(images[index], isOriginal: true),
        );
  }

  @override
  Widget build(BuildContext context) {
    Size orientatedSize = images[index].orientatedSize;

    return Scaffold(
        body: SafeArea(
            child: GestureDetector(
                onTap: () => setState(() {
                      decorationVisible = !decorationVisible;
                    }),
                child: Stack(children: <Widget>[
                  Hero(
                    tag: images[index].id,
                    child: PhotoViewGallery.builder(
                      pageController: widget.pageController,
                      loadingBuilder: (context, event) {
                        return Center(
                          child: AspectRatio(
                            aspectRatio:
                                orientatedSize.width / orientatedSize.height,
                            child: Container(
                              color: Colors.white12,
                            ),
                          ),
                        );
                      },
                      allowImplicitScrolling: true,
                      itemCount: widget.imageTotal,
                      builder: _buildItem,
                      onPageChanged: (index) => setState(() {
                        this.index = index;
                      }),
                    ),
                  ),
                  AnimatedOpacity(
                      opacity: decorationVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.arrow_back)),
                                  Text(
                                    "${index + 1}/${widget.imageTotal}",
                                    style: imageIndexTextStyle(),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.delete)),
                                ],
                              )
                            ],
                          )))
                ]))));
  }
}
