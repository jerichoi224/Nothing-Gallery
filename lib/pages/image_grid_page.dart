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
  bool useTrashBin = true;

  @override
  void initState() {
    super.initState();
    albumInfo = widget.album;
    totalCount = albumInfo.assetCount;
    getPreferences();
    refreshGrid();

    final appStatus = Provider.of<AppStatus>(context, listen: false);

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      if (appStatus.activeTab == 0) return;

      switch (validateEventType(event)) {
        case EventType.assetDeleted:
          setState(() {
            assets.removeWhere(
                (image) => (event.details as List<String>).contains(image.id));
            images.removeWhere(
                (image) => (event.details as List<String>).contains(image.id));
            totalCount -= 1;
          });

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

  void refreshGrid() {
    assets = albumInfo.preloadImages;
    images = assets.where((asset) => asset.type == AssetType.image).toList();
    getImages();
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

    while (assets.length < albumInfo.assetCount) {
      newAssets =
          await loadAssets(albumInfo.pathEntity, ++currentPage, size: 80);
      if (newAssets.isEmpty) break;

      assets = List.from(assets)..addAll(newAssets);
      images = List.from(images)
        ..addAll(newAssets.where((asset) => asset.type == AssetType.image));
    }
    setState(() {});
  }

  Widget gridPageWrapper(ImageSelection imageSelection, Widget child) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: WillPopScope(
                onWillPop: () async {
                  if (imageSelection.selectionMode) {
                    imageSelection.endSelection();
                    return false;
                  }
                  Navigator.pop(context);
                  return true;
                },
                child: SafeArea(child: child))));
  }

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) {
      Future.microtask(() => Navigator.pop(context));
      return Container();
    } else {
      return Consumer<ImageSelection>(
          builder: (context, imageSelection, child) {
        return gridPageWrapper(
            imageSelection,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                    child: Text(
                      "${albumInfo.pathEntity.name.toUpperCase()} (${albumInfo.assetCount})",
                      style: mainTextStyle(TextStyleType.gridPageTitle),
                    )),
                const Spacer(),
                imageSelection.selectionMode
                    ? SelectionMenuWidget(
                        assets: assets,
                        showMore: true,
                      )
                    : Container()
              ]),

              // Images Grid
              Expanded(
                  child: CustomScrollView(
                primary: false,
                slivers: <Widget>[
                  SliverGrid.count(
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      crossAxisCount: numCol,
                      childAspectRatio: 1,
                      children: assets
                          .asMap()
                          .entries
                          .map((entry) => GridItemWidget(asset: entry.value))
                          .toList()),
                ],
              ))
            ]));
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
  void onResumed() async {
    List<AlbumInfo> updatedAlbum =
        await getCurrentAlbumStates([albumInfo.pathEntity.id]);

    if (updatedAlbum.isEmpty) return;
    albumInfo = updatedAlbum[0];
    refreshGrid();
  }

  @override
  void onHidden() {
    // TODO: implement onResumed
  }
}
