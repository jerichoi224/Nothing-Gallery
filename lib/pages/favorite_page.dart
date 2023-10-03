import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/util/util.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State createState() => _FavoriteState();
}

class _FavoriteState extends LifecycleListenerState<FavoritePage> {
  late AlbumInfo recent;
  List<AssetEntity> assets = [];
  List<AssetEntity> images = [];
  StreamSubscription? eventSubscription;

  int currentPage = 0;
  int startingIndex = 0;
  int totalLoaded = 0;
  int numCol = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final albumInfoList = Provider.of<AlbumInfoList>(context, listen: false);
      final appStatus = Provider.of<AppStatus>(context, listen: false);

      recent = albumInfoList.recent;
      assets = [...recent.preloadImages];
      totalLoaded = assets.length;

      assets.removeWhere((asset) => !appStatus.favoriteIds.contains(asset.id));
      images = assets.where((asset) => asset.type == AssetType.image).toList();

      getFavorites(appStatus);

      eventSubscription =
          eventController.stream.asBroadcastStream().listen((event) {
        switch (validateEventType(event)) {
          case EventType.assetDeleted:
          case EventType.favoriteRemoved:
            setState(() {
              assets.removeWhere((asset) =>
                  (event.details as List<String>).contains(asset.id));
              images.removeWhere((image) =>
                  (event.details as List<String>).contains(image.id));
            });
            break;
          case EventType.videoOpen:
            openVideoPlayerPage(context, event.details);
            break;
          case EventType.pictureOpen:
            openImagePage(
                context, images.indexOf(event.details), images.length, images,
                favoritesPage: true);
            break;
          default:
        }
      });
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> getFavorites(AppStatus appStatus) async {
    List<AssetEntity> newAssets =
        await loadAssets(recent.pathEntity, ++currentPage, size: 80);
    totalLoaded += newAssets.length;

    newAssets.removeWhere((asset) => !appStatus.favoriteIds.contains(asset.id));
    assets = List.from(assets)..addAll(newAssets);

    assets = List.from(assets)..addAll(newAssets);
    images = List.from(images)
      ..addAll(newAssets.where((asset) => asset.type == AssetType.image));

    setState(() {});

    while (assets.length < recent.assetCount) {
      newAssets = await loadAssets(recent.pathEntity, ++currentPage, size: 80);
      if (newAssets.isEmpty) break;
      totalLoaded += newAssets.length;

      newAssets
          .removeWhere((asset) => !appStatus.favoriteIds.contains(asset.id));

      assets = List.from(assets)..addAll(newAssets);
      images = List.from(images)
        ..addAll(newAssets.where((asset) => asset.type == AssetType.image));
    }
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
    return Consumer<AppStatus>(builder: (context, appStatus, child) {
      if (appStatus.favoriteIds.isEmpty) {
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
                        "FAVORITES (${appStatus.favoriteIds.length})",
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
    });
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
  void onResumed() async {}

  @override
  void onHidden() {
    // TODO: implement onResumed
  }
}