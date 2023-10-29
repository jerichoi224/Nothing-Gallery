// ignore: file_names
import 'dart:async';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/util/util.dart';

class ImagePageWidget extends StatefulWidget {
  final int currentIndex;
  final int imageTotal;
  final PageController pageController;
  final List<AssetEntity> images;
  final bool favoritesPage;

  ImagePageWidget(
      {super.key,
      required this.images,
      required this.imageTotal,
      required this.currentIndex,
      required this.favoritesPage})
      : pageController = PageController(initialPage: currentIndex);

  @override
  State createState() => _ImagePageWidgetState();
}

class _ImagePageWidgetState extends State<ImagePageWidget>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int imageTotal = 0;
  List<AssetEntity> images = [];
  bool decorationVisible = true;

  late AnimationController animationController;
  late Animation fadeAnimation;
  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    currentIndex = widget.currentIndex;
    imageTotal = widget.imageTotal;
    images = [...widget.images];

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    fadeAnimation = Tween(begin: 0, end: 1).animate(animationController);

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      switch (validateEventType(event)) {
        case EventType.favoriteRemoved:
          if (widget.favoritesPage) {
            images.removeAt(currentIndex);
            if (images.length == currentIndex) {
              currentIndex--;
            }
            imageTotal -= 1;
            setState(() {});
          }
          break;
        case EventType.assetMoved:
        case EventType.assetDeleted:
          if (images.length == currentIndex) {
            currentIndex--;
          }
          images.removeAt(currentIndex);

          imageTotal -= 1;

          setState(() {});
          break;
        default:
      }
    });
  }

  void toggleStatusBar(bool show) {
    if (show) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    eventSubscription?.cancel();
    toggleStatusBar(true);
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    Size orientatedSize = images[index].orientatedSize;
    return PhotoViewGalleryPageOptions(
        minScale: min(MediaQuery.of(context).size.width / orientatedSize.width,
            MediaQuery.of(context).size.height / orientatedSize.height),
        imageProvider: AssetEntityImage(
          images[index],
          isOriginal: true,
        ).image);
  }

  Widget imagePageWrapper(Widget child) {
    return Scaffold(
        body: WillPopScope(
            onWillPop: () async {
              if (Navigator.canPop(context)) Navigator.pop(context);
              return true;
            },
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() {
                      decorationVisible = !decorationVisible;
                      toggleStatusBar(decorationVisible);
                    }),
                child: child)));
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    var bottom = MediaQuery.of(context).viewPadding.bottom;

    if (images.isEmpty) {
      Future.microtask(() => Navigator.pop(context));
      return Container();
    } else {
      return imagePageWrapper(Stack(children: <Widget>[
        ExtendedImageGesturePageView.builder(
          itemBuilder: (BuildContext context, int index) {
            var file = widget.images[index].file;
            Widget image = ExtendedImage(
              image: AssetEntityImage(
                images[index],
                isOriginal: true,
              ).image,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (ExtendedImageState state) {
                return GestureConfig(
                  //you must set inPageView true if you want to use ExtendedImageGesturePageView
                  inPageView: true,
                  initialScale: 1.0,
                  maxScale: 5.0,
                  animationMaxScale: 6.0,
                  initialAlignment: InitialAlignment.center,
                );
              },
            );

            image = Container(
              child: image,
              padding: EdgeInsets.all(5.0),
            );
            if (index == currentIndex) {
              return Hero(
                tag: images[currentIndex].id,
                child: image,
              );
            } else {
              return image;
            }
          },
          itemCount: imageTotal,
          onPageChanged: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
          controller: ExtendedPageController(
            initialPage: currentIndex,
          ),
          scrollDirection: Axis.horizontal,

          // PhotoViewGallery.builder(
          //   pageController: widget.pageController,
          //   loadingBuilder: (context, event) {
          //     return Container(color: Colors.black);
          //     // Image(
          //     //     fit: BoxFit.contain,
          //     //     image: AssetEntityImageProvider(
          //     //       images[index],
          //     //       isOriginal: false,
          //     //     ));
          //   },
          //   allowImplicitScrolling: true,
          //   itemCount: imageTotal,
          //   builder: _buildItem,
          //   onPageChanged: (index) => setState(() {
          //     this.index = index;
          //   }),
          // ),
        ),
        AnimatedOpacity(
            opacity: decorationVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Column(
              children: [
                Container(
                  height: height,
                  color: const Color.fromARGB(150, 0, 0, 0),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.00, 0.3, 1],
                      colors: [
                        Color.fromARGB(150, 0, 0, 0),
                        Color.fromARGB(130, 0, 0, 0),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.arrow_back)),
                      Text(
                        "${currentIndex + 1}/$imageTotal",
                        style: mainTextStyle(TextStyleType.imageIndex),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.00, 1],
                      colors: [
                        Colors.transparent,
                        Color.fromARGB(150, 0, 0, 0),
                      ],
                    ),
                  ),
                  child: SingleItemBottomMenu(
                    asset: images[currentIndex],
                    popOnDelete: false,
                    parentContext: context,
                    favoritesPage: widget.favoritesPage,
                  ),
                ),
                SizedBox(
                  height: bottom,
                )
              ],
            ))
      ]));
    }
  }
}
