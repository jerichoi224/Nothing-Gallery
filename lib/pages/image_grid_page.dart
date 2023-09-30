import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/util/util.dart';

class ImageGridWidget extends StatefulWidget {
  final AlbumInfo album;

  const ImageGridWidget({super.key, required this.album});

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
  bool useTrashBin = true;

  AlbumState albumState = AlbumState.notModified;

  @override
  void initState() {
    super.initState();
    albumInfo = widget.album;
    totalCount = albumInfo.assetCount;
    assets = [];
    images = [];
    images.removeWhere((element) => element.type != AssetType.image);

    getPreferences();
    getImages();

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      switch (validateEventType(event)) {
        case EventType.pictureDeleted:
          assets.removeWhere((image) => image.id == event.details);
          images.removeWhere((image) => image.id == event.details);
          totalCount -= 1;

          // Album is empty
          if (totalCount == 0) {
            eventController.sink
                .add(Event(EventType.albumEmpty, albumInfo.pathEntity.id));
          }
          break;
        case EventType.videoOpen:
          openVideoPlayerPage(context, event.details);
          break;
        case EventType.pictureOpen:
          openImagePage(
              context, images.indexOf(event.details), images.length, images);
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
  }

  void getPreferences() {
    numCol = sharedPref.get(SharedPrefKeys.imageGridPageNumCol);
    useTrashBin = sharedPref.get(SharedPrefKeys.useTrashBin);
  }

  Future<void> getImages() async {
    if (assets.length >= albumInfo.assetCount) return;

    List<AssetEntity> newAssets =
        await loadAssets(albumInfo.pathEntity, ++currentPage, size: 80);
    setState(() {
      assets = List.from(assets)..addAll(newAssets);
      images = List.from(images)
        ..addAll(newAssets.where((asset) => asset.type == AssetType.image));
    });
  }

  Future<void> onDelete(
      List<AssetEntity> selectedAssets, ImageSelection imageSelection) async {
    List<String> deletedImages =
        await confirmDelete(context, selectedAssets, useTrashBin);
    if (deletedImages.isNotEmpty) {
      for (String imageId in deletedImages) {
        eventController.sink.add(Event(EventType.pictureDeleted, imageId));
      }
      imageSelection.endSelection();
    }
  }

  Widget selectionModeMenu(ImageSelection imageSelection) {
    List<AssetEntity> selectedAssets = assets
        .where((element) => imageSelection.selectedIds.contains(element.id))
        .toList();

    return Row(children: [
      IconButton(
        onPressed: () {
          shareFiles(selectedAssets);
        },
        icon: const Icon(Icons.share),
      ),
      IconButton(
        onPressed: () {
          onDelete(selectedAssets, imageSelection);
        },
        icon: const Icon(Icons.delete),
      ),
      PopupMenuButton<SelectedImageMenu>(
          onSelected: (SelectedImageMenu item) {},
          itemBuilder: (BuildContext context) {
            return [
              for (final value in SelectedImageMenu.values)
                PopupMenuItem(
                  value: value,
                  child: Text(
                    value.text,
                    style: mainTextStyle(TextStyleType.videoDuration),
                  ),
                )
            ];
          }),
    ]);
  }

  Widget gridPageWrapper(Widget child) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: SafeArea(
                child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scroll) {
                      final scrollPixels = scroll.metrics.pixels /
                          scroll.metrics.maxScrollExtent;
                      if (scrollPixels > 0.6) {
                        getImages();
                      }
                      return false;
                    },
                    child: child))));
  }

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) {
      Future.microtask(() => Navigator.pop(context));
      return Container();
    } else {
      return ChangeNotifierProvider<ImageSelection>(
          create: (_) => ImageSelection(),
          builder: (context, child) {
            return Consumer<ImageSelection>(
                builder: (context, imageSelection, child) {
              return gridPageWrapper(WillPopScope(
                  onWillPop: () async {
                    if (imageSelection.selectionMode) {
                      imageSelection.endSelection();
                      return false;
                    }
                    Navigator.pop(context, albumState);
                    return true;
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    albumInfo.pathEntity.name.toUpperCase(),
                                    style:
                                        mainTextStyle(TextStyleType.pageTitle),
                                  )),
                              const Spacer(),
                              imageSelection.selectionMode
                                  ? selectionModeMenu(imageSelection)
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
                                      .map((entry) =>
                                          GridItemWidget(asset: entry.value))
                                      .toList()),
                            ),
                          ],
                        ))
                      ])));
            });
          });
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

  @override
  void onHidden() {
    // TODO: implement onResumed
  }
}
