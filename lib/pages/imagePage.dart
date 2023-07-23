// ignore: file_names
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/constants/sharedPrefKey.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/imageFunctions.dart';
import 'package:photo_manager/photo_manager.dart';
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
  bool decorationVisible = true;
  bool useTrashBin = true;
  bool isFavorite = false;

  late AnimationController animationController;
  late Animation fadeAnimation;

  @override
  void initState() {
    super.initState();
    getPreferences();

    index = widget.index;
    images = widget.images;
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    fadeAnimation = Tween(begin: 0, end: 1).animate(animationController);
  }

  void getPreferences() {
    useTrashBin = sharedPref.get(SharedPrefKeys.useTrashBin);
    checkFavorite();
  }

  void checkFavorite() {
    setState(() {
      isFavorite =
          sharedPref.get(SharedPrefKeys.favoriteIds).contains(images[index].id);
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    Size orientatedSize = images[index].orientatedSize;
    // if (images[index].type == AssetType.video) {
    // } else
    {
      return PhotoViewGalleryPageOptions(
          minScale: min(
              MediaQuery.of(context).size.width / orientatedSize.width,
              MediaQuery.of(context).size.height / orientatedSize.height),
          imageProvider: AssetEntityImage(
            images[index],
            isOriginal: true,
          ).image);
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
                      itemCount: widget.imageTotal,
                      builder: _buildItem,
                      onPageChanged: (index) => setState(() {
                        this.index = index;
                        checkFavorite();
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setFavorite(
                                            images[index].id, !isFavorite);
                                        setState(() {
                                          isFavorite = !isFavorite;
                                        });
                                      },
                                      icon: Icon(isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border_outlined)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.share)),
                                  IconButton(
                                      onPressed: () {
                                        confirmDelete(
                                            context,
                                            [
                                              images[index],
                                            ],
                                            useTrashBin);
                                      },
                                      icon: const Icon(Icons.delete)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.more_vert)),
                                ],
                              )
                            ],
                          )))
                ]))));
  }
}
