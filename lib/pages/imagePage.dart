import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// ignore: must_be_immutable
class ImagePageWidget extends StatefulWidget {
  int index;
  int imageTotal;
  final PageController pageController;
  List<AssetEntity> images;

  ImagePageWidget(
      {super.key,
      required this.images,
      required this.imageTotal,
      required this.index})
      : pageController = PageController(initialPage: index);

  @override
  State createState() => _ImagePageWidgetState();
}

class _ImagePageWidgetState extends State<ImagePageWidget>
    with SingleTickerProviderStateMixin {
  int index = 0;
  List<AssetEntity> images = [];
  bool decorationVisible = false;

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

  PhotoViewScaleState myScaleStateCycle(PhotoViewScaleState actual) {
    switch (actual) {
      case PhotoViewScaleState.zoomedIn:
      case PhotoViewScaleState.zoomedOut:
      case PhotoViewScaleState.covering:
        return PhotoViewScaleState.initial;
      case PhotoViewScaleState.initial:
      case PhotoViewScaleState.originalSize:
      default:
        return PhotoViewScaleState.covering;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: GestureDetector(
                onTap: () => setState(() {
                      decorationVisible = !decorationVisible;
                    }),
                child: Stack(children: <Widget>[
                  PhotoViewGallery.builder(
                    // loadingBuilder:
                    allowImplicitScrolling: true,
                    pageController: widget.pageController,
                    itemCount: widget.imageTotal,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                          imageProvider: AssetEntityImageProvider(images[index],
                              isOriginal: true));
                    },
                    onPageChanged: (index) => setState(() {
                      this.index = index;
                    }),
                  ),
                  AnimatedOpacity(
                      // If the widget is visible, animate to 0.0 (invisible).
                      // If the widget is hidden, animate to 1.0 (fully visible).
                      opacity: decorationVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      // The green box must be a child of the AnimatedOpacity widget.
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                "${index + 1}/${widget.imageTotal}",
                                style: bottomNavTextStyle(),
                              ),
                              const Spacer(),
                              Text("HELLO", style: bottomNavTextStyle())
                            ],
                          )))
                ]))));
  }
}
