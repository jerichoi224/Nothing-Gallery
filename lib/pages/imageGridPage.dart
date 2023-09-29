import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/classes/LifeCycleListenerState.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/constants/albumStatus.dart';
import 'package:nothing_gallery/constants/eventType.dart';
import 'package:nothing_gallery/constants/imageWidgetStatus.dart';
import 'package:nothing_gallery/constants/selectedImageMenu.dart';
import 'package:nothing_gallery/constants/sharedPrefKey.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/pages/videoPlayerPage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/imageFunctions.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGridWidget extends StatefulWidget {
  final AlbumInfo album;
  late SharedPref sharedPref;
  late StreamController eventController;

  ImageGridWidget(
      {super.key,
      required this.album,
      required this.sharedPref,
      required this.eventController});

  @override
  State createState() => _ImageGridState();
}

class _ImageGridState extends LifecycleListenerState<ImageGridWidget> {
  late AlbumInfo albumInfo;
  List<AssetEntity> images = [];
  List<AssetEntity> assets = [];
  StreamSubscription? eventSubscription;
  int totalCount = 0;
  int currentPage = 0;
  int numCol = 4;
  int loadImageCount = 100;
  bool selectionMode = false;
  bool useTrashBin = true;
  List<String> selected = [];

  AlbumState albumState = AlbumState.notModified;

  @override
  void initState() {
    super.initState();
    albumInfo = widget.album;
    totalCount = albumInfo.assetCount;
    assets = albumInfo.images;
    images = List.from(assets);
    images.removeWhere((element) => element.type != AssetType.image);

    getPreferences();
    eventSubscription =
        widget.eventController.stream.asBroadcastStream().listen((event) {
      if (event.runtimeType == Event) {
        if (event.eventType == EventType.pictureDeleted) {
          if (event.details != null && event.details.runtimeType == String) {
            assets.removeWhere((image) => image.id == event.details);
            images.removeWhere((image) => image.id == event.details);
            totalCount -= 1;

            // Album is empty
            if (totalCount == 0) {
              widget.eventController.sink
                  .add(Event(EventType.albumEmpty, albumInfo.album.id));
            }
          }
        } else {}
      }
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
  }

  void getPreferences() {
    numCol = widget.sharedPref.get(SharedPrefKeys.imageGridPageNumCol);
    useTrashBin = sharedPref.get(SharedPrefKeys.useTrashBin);
  }

  void toggleSelection(String imageId) {
    if (selected.contains(imageId)) {
      selected.remove(imageId);
    } else {
      selected.add(imageId);
    }
    if (selected.isNotEmpty) {
      selectionMode = true;
    }
    setState(() {});
  }

  Future<void> onDelete() async {
    List<String> deletedImages = await confirmDelete(
        context,
        assets.where((element) => selected.contains(element.id)).toList(),
        useTrashBin);
    if (deletedImages.isNotEmpty) {
      for (String imageId in deletedImages) {
        widget.eventController.sink
            .add(Event(EventType.pictureDeleted, imageId));
      }
      setState(() {});
    }
  }

  void _onImageTap(AssetEntity image, int index) async {
    if (selectionMode) {
      toggleSelection(image.id);
    } else {
      if (image.type == AssetType.image) {
        int imageIdx = images.indexOf(image);
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePageWidget(
                images: images,
                imageTotal: images.length,
                index: imageIdx,
                eventController: widget.eventController,
              ),
            ));
      } else if (image.type == AssetType.video) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPageWidget(
                video: image,
                eventController: widget.eventController,
              ),
            ));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) {
      Future.microtask(() => Navigator.pop(context));
      return Container();
    } else {
      return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
              body: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scroll) {
                    // 현재 스크롤 위치 - scroll.metrics.pixels
                    // 스크롤 끝 위치 scroll.metrics.maxScrollExtent
                    // final scrollPixels =
                    //     scroll.metrics.pixels / scroll.metrics.maxScrollExtent;

                    // if (scrollPixels > 0.6) {}
                    return false;
                  },
                  child: WillPopScope(
                      onWillPop: () async {
                        if (selectionMode) {
                          setState(() {
                            selected.clear();
                            selectionMode = false;
                          });
                          return false;
                        }
                        Navigator.pop(context, albumState);
                        return true;
                      },
                      child: SafeArea(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        albumInfo.album.name.toUpperCase(),
                                        style: mainTextStyle(
                                            TextStyleType.pageTitle),
                                      )),
                                  const Spacer(),
                                  selected.isNotEmpty
                                      ? Row(children: [
                                          IconButton(
                                            onPressed: () {
                                              shareFiles(
                                                assets
                                                    .where((element) => selected
                                                        .contains(element.id))
                                                    .toList(),
                                              );
                                            },
                                            icon: const Icon(Icons.share),
                                          ),
                                          IconButton(
                                            onPressed: onDelete,
                                            icon: const Icon(Icons.delete),
                                          ),
                                          PopupMenuButton<SelectedImageMenu>(
                                              onSelected:
                                                  (SelectedImageMenu item) {},
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  for (final value
                                                      in SelectedImageMenu
                                                          .values)
                                                    PopupMenuItem(
                                                      value: value,
                                                      child: Text(
                                                        value.text,
                                                        style: mainTextStyle(
                                                            TextStyleType
                                                                .videoDuration),
                                                      ),
                                                    )
                                                ];
                                              }),
                                        ])
                                      : Container()
                                ]),

                            // Images Grid
                            Expanded(
                                child: CustomScrollView(
                              primary: false,
                              slivers: <Widget>[
                                SliverPadding(
                                  padding: const EdgeInsets.all(12),
                                  sliver: SliverGrid.count(
                                      crossAxisSpacing: 3,
                                      mainAxisSpacing: 3,
                                      crossAxisCount: numCol,
                                      childAspectRatio: 1,
                                      children: assets
                                          .asMap()
                                          .entries
                                          .map((entry) => imageWidget(
                                              () => {
                                                    _onImageTap(
                                                        entry.value, entry.key)
                                                  },
                                              entry.value,
                                              selectionMode
                                                  ? selected.contains(
                                                          entry.value.id)
                                                      ? ImageWidgetStatus
                                                          .selected
                                                      : ImageWidgetStatus
                                                          .unselected
                                                  : ImageWidgetStatus.normal,
                                              (String imageId) =>
                                                  {toggleSelection(imageId)}))
                                          .toList()),
                                ),
                              ],
                            ))
                          ]))))));
    }
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }
}
