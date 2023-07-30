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
import 'package:share_plus/share_plus.dart';

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
  int imageTotal = 0;
  List<AssetEntity> images = [];
  List<String> favoriteIds = [];
  bool decorationVisible = true;
  bool useTrashBin = true;
  bool isFavorite = false;
  List<String> itemDeleted = [];

  late AnimationController animationController;
  late Animation fadeAnimation;

  @override
  void initState() {
    super.initState();

    index = widget.index;
    imageTotal = widget.imageTotal;
    images = widget.images;
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    fadeAnimation = Tween(begin: 0, end: 1).animate(animationController);

    getPreferences();
  }

  void getPreferences() {
    useTrashBin = sharedPref.get(SharedPrefKeys.useTrashBin);
    favoriteIds = (sharedPref.get(SharedPrefKeys.favoriteIds) as List)
        .map((item) => item as String)
        .toList();
    checkFavorite();
  }

  void checkFavorite() {
    setState(() {
      isFavorite = favoriteIds.contains(images[index].id);
    });
  }

  void setFavorite(bool favorite) {
    String imageId = images[index].id;
    if (favorite) {
      if (!favoriteIds.contains(imageId)) {
        favoriteIds.add(imageId);
      }
    } else if (favoriteIds.contains(imageId)) {
      favoriteIds.remove(imageId);
    }

    sharedPref.set(SharedPrefKeys.favoriteIds, favoriteIds);
    checkFavorite();
  }

  Future<void> onDelete() async {
    List<String> deleted = await confirmDelete(
        context,
        [
          images[index],
        ],
        useTrashBin);
    if (deleted.isNotEmpty) {
      itemDeleted = List.from(itemDeleted)..addAll(deleted);

      imageTotal -= 1;
      if (images.length == 1) {
        images.removeAt(index);
        Navigator.pop(context, itemDeleted);
      }
      if (images.length == index + 1) {
        index--;
        await widget.pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
        images.removeAt(index + 1);
        setState(() {});
      } else {
        index++;
        await widget.pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
        index--;
        widget.pageController.jumpToPage(index);
        images.removeAt(index);
        setState(() {});
      }
    }
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
    if (images.length <= index) {
      Navigator.pop(context, itemDeleted);
    }

    return Scaffold(
        body: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, itemDeleted);
              return itemDeleted.isNotEmpty;
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
                                            Navigator.pop(context, itemDeleted);
                                          },
                                          icon: const Icon(Icons.arrow_back)),
                                      Text(
                                        "${index + 1}/${imageTotal}",
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
                                            setFavorite(!isFavorite);
                                          },
                                          icon: Icon(isFavorite
                                              ? Icons.favorite
                                              : Icons
                                                  .favorite_border_outlined)),
                                      IconButton(
                                          onPressed: () {
                                            shareFiles([images[index]]);
                                          },
                                          icon: const Icon(Icons.share)),
                                      IconButton(
                                          onPressed: onDelete,
                                          icon: const Icon(Icons.delete)),
                                      IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.more_vert)),
                                    ],
                                  )
                                ],
                              )))
                    ])))));
  }
}
