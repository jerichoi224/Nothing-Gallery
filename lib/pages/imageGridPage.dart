import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/classes/LifeCycleListenerState.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/constants/albumStatus.dart';
import 'package:nothing_gallery/constants/eventType.dart';
import 'package:nothing_gallery/constants/sharedPrefKey.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/style.dart';
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
  }

  void _openImage(AssetEntity image, int index) async {
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
    }
    setState(() {});
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
                        Navigator.pop(context, albumState);
                        return true;
                      },
                      child: SafeArea(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  albumInfo.album.name.toUpperCase(),
                                  style: pageTitleTextStyle(),
                                )),

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
                                                  _openImage(
                                                      entry.value, entry.key)
                                                },
                                                entry.value,
                                              ))
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
  void onResumed() {}
}
