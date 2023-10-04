// ignore: file_names
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/util/util.dart';

// ignore: must_be_immutable
class ImagePageWidget extends StatefulWidget {
  int index;
  int imageTotal;
  final PageController pageController;
  List<AssetEntity> images;
  bool favoritesPage;

  ImagePageWidget(
      {super.key,
      required this.images,
      required this.imageTotal,
      required this.index,
      required this.favoritesPage})
      : pageController = PageController(initialPage: index);

  @override
  State createState() => _ImagePageWidgetState();
}

class _ImagePageWidgetState extends State<ImagePageWidget>
    with SingleTickerProviderStateMixin {
  int index = 0;
  int imageTotal = 0;
  List<AssetEntity> images = [];
  List<String> favoriteIds = [];
  bool decorationVisible = true;
  bool useTrashBin = true;

  late AnimationController animationController;
  late Animation fadeAnimation;
  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();

    index = widget.index;
    imageTotal = widget.imageTotal;
    images = [...widget.images];
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    fadeAnimation = Tween(begin: 0, end: 1).animate(animationController);

    getPreferences();

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      switch (validateEventType(event)) {
        case EventType.favoriteRemoved:
          if (widget.favoritesPage) {
            images.removeAt(index);
            if (images.length == index) {
              index--;
            }
            imageTotal -= 1;
            setState(() {});
          }
          break;

        case EventType.assetDeleted:
          if (images.length == index) {
            index--;
          }
          images.removeAt(index);

          imageTotal -= 1;
          setState(() {});
          break;
        default:
      }
    });
  }

  void getPreferences() {
    useTrashBin = sharedPref.get(SharedPrefKeys.useTrashBin);
    favoriteIds = (sharedPref.get(SharedPrefKeys.favoriteIds) as List)
        .map((item) => item as String)
        .toList();
  }

  @override
  void dispose() {
    animationController.dispose();
    eventSubscription?.cancel();
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
        ).image);
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      Future.microtask(() => Navigator.pop(context));
      return Container();
    } else {
      return Scaffold(
          body: WillPopScope(
              onWillPop: () async {
                Navigator.pop(context);
                return true;
              },
              child: SafeArea(
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
                              return Image(
                                  fit: BoxFit.contain,
                                  image: AssetEntityImageProvider(
                                    images[index],
                                    isOriginal: false,
                                  ));
                            },
                            allowImplicitScrolling: true,
                            itemCount: imageTotal,
                            builder: _buildItem,
                            onPageChanged: (index) => setState(() {
                              this.index = index;
                            }),
                          ),
                        ),
                        AnimatedOpacity(
                            opacity: decorationVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.00, 1],
                                      colors: [
                                        Color.fromARGB(150, 0, 0, 0),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.arrow_back)),
                                      Text(
                                        "${index + 1}/$imageTotal",
                                        style: mainTextStyle(
                                            TextStyleType.imageIndex),
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
                                      asset: images[index],
                                      popOnDelete: false,
                                      parentContext: context,
                                    ))
                              ],
                            ))
                      ])))));
    }
  }
}
