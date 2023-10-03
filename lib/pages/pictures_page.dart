import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/constants/settings_pref.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/util/util.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/model/model.dart';

class PicturesWidget extends StatefulWidget {
  const PicturesWidget({super.key});

  @override
  State createState() => _PicturesState();
}

class _PicturesState extends State<PicturesWidget>
    with AutomaticKeepAliveClientMixin {
  late AlbumInfo recent;
  List<AssetEntity> assets = [];
  List<AssetEntity> images = [];

  Map<DateTime, List<AssetEntity>> dateMap = {};
  int totalCount = 0;
  int currentPage = 0;

  int startingIndex = 0;

  StreamSubscription? eventSubscription;

  List<String> monthAbrev = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
    "Jan"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final albumInfoList = Provider.of<AlbumInfoList>(context, listen: false);
      final appStatus = Provider.of<AppStatus>(context, listen: false);

      recent = albumInfoList.recent;
      totalCount = recent.assetCount;
      assets = recent.preloadImages;
      images = assets.where((asset) => asset.type == AssetType.image).toList();
      getImages();

      eventSubscription =
          eventController.stream.asBroadcastStream().listen((event) {
        if (appStatus.activeTab == InitialScreen.albums.tabIndex) return;
        switch (validateEventType(event)) {
          case EventType.assetDeleted:
            List<AssetEntity> deletedAssets = assets
                .where((image) =>
                    (event.details as List<String>).contains(image.id))
                .toList();

            for (AssetEntity asset in deletedAssets) {
              DateTime dateTaken = asset.createDateTime;
              DateTime date =
                  DateTime(dateTaken.year, dateTaken.month, dateTaken.day);
              dateMap[date]?.removeWhere((element) => element.id == asset.id);
              if (dateMap[date]!.isEmpty) {
                dateMap.remove(date);
              }
            }

            setState(() {
              assets.removeWhere((image) =>
                  (event.details as List<String>).contains(image.id));
              images.removeWhere((image) =>
                  (event.details as List<String>).contains(image.id));
            });

            totalCount -= 1;
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
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> getImages() async {
    List<AssetEntity> newAssets =
        await loadAssets(recent.pathEntity, ++currentPage, size: 80);
    assets = List.from(assets)..addAll(newAssets);
    images = List.from(images)
      ..addAll(newAssets.where((asset) => asset.type == AssetType.image));

    startingIndex = await buildImageChunks(startingIndex);
    setState(() {});

    while (assets.length < recent.assetCount) {
      newAssets = await loadAssets(recent.pathEntity, ++currentPage, size: 80);
      if (newAssets.isEmpty) break;

      assets = List.from(assets)..addAll(newAssets);
      images = List.from(images)
        ..addAll(newAssets.where((asset) => asset.type == AssetType.image));
      buildImageChunks(startingIndex).then((value) {
        setState(() {
          startingIndex = value;
        });
      });
    }
  }

  Future<int> buildImageChunks(int startingIndex) async {
    for (AssetEntity asset in assets.sublist(startingIndex)) {
      DateTime dateTaken = asset.createDateTime;
      DateTime date = DateTime(dateTaken.year, dateTaken.month, dateTaken.day);

      dateMap.putIfAbsent(date, () => []);
      dateMap[date]!.add(asset);
    }
    return assets.length;
  }

  Widget picturesPageWrapper(ImageSelection imageSelection, Widget child) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: WillPopScope(
                onWillPop: () async {
                  if (imageSelection.selectionMode) {
                    imageSelection.endSelection();
                    return false;
                  }
                  return true;
                },
                child: SafeArea(child: child))));
  }

  Widget _buildDateChunk(
      BuildContext context, MapEntry<DateTime, List<AssetEntity>> entry) {
    String dateText = entry.key.year == DateTime.now().year
        ? "${monthAbrev[entry.key.month]} ${entry.key.day}"
        : "${entry.key.year} ${monthAbrev[entry.key.month]} ${entry.key.day}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Text(
            dateText,
            style: mainTextStyle(TextStyleType.picturesDateTaken),
          ),
        ),
        GridView.count(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            primary: false,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            shrinkWrap: true,
            crossAxisCount: 4,
            children: entry.value.map((entry) {
              return GridItemWidget(asset: entry);
            }).toList())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var dateList = dateMap.entries.toList();
    dateList.sort((a, b) => b.key.compareTo(a.key));

    return Consumer<ImageSelection>(builder: (context, imageSelection, child) {
      return picturesPageWrapper(
          imageSelection,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'TIMELINE',
                      style: mainTextStyle(TextStyleType.pageTitle),
                    ),
                    const Spacer(),
                    imageSelection.selectionMode
                        ? SelectionMenuWidget(
                            assets: assets,
                            showMore: false,
                          )
                        : IconButton(
                            onPressed: () {}, icon: const Icon(Icons.search))
                  ],
                )),
            // Album Grid
            Expanded(
              child: CustomScrollView(primary: false, slivers: <Widget>[
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildDateChunk(context, dateList[index]),
                  childCount: dateList.length,
                ))
              ]),
            )
          ]));
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
