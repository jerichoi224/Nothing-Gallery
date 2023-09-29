import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/constants/eventType.dart';
import 'package:nothing_gallery/constants/imageWidgetStatus.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/pages/videoPlayerPage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

class PicturesWidget extends StatefulWidget {
  PicturesWidget({super.key});

  @override
  State createState() => _PicturesState();
}

class _PicturesState extends State<PicturesWidget> {
  late AssetPathEntity recent;
  List<AssetEntity> unusedImages = [];
  List<AssetEntity> loadedImages = [];
  List<AssetEntity> images = [];
  List<Widget> chunksByDate = [];
  int totalLoaded = 0;
  StreamSubscription? eventSubscription;

  bool selectionMode = false;
  List<String> selected = [];

  int currentPage = 0;
  int loadImageCount = 100;

  List<String> monthAbrev = [
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

  PMFilter createFilter() {
    final CustomFilter filterOption = CustomFilter.sql(
      where:
          '${CustomColumns.base.width} > 100 AND ${CustomColumns.base.height} > 100',
      orderBy: [OrderByItem.desc(CustomColumns.base.createDate)],
    );

    return filterOption;
  }

  @override
  void initState() {
    super.initState();

    // loadMoreDates();
    images = []; // List.from(widget.pictures);
    images.removeWhere((element) => element.type != AssetType.image);

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      if (event.runtimeType == Event) {
        if (event.eventType == EventType.pictureDeleted) {
          if (event.details != null && event.details.runtimeType == String) {
            images.removeWhere((image) => image.id == event.details);
          }
        } else {}
      }
    });
  }

  List<AssetEntity> loadImages() {
    currentPage += 1;
    return [];
    // widget.pictures.sublist((currentPage - 1) * loadImageCount,
    //     min(currentPage * loadImageCount, widget.pictures.length));
  }

  Future<void> loadMoreDates() async {
    do {
      List<AssetEntity> newlyLoaded = loadImages();
      loadedImages.addAll(newlyLoaded);
      unusedImages.addAll(newlyLoaded);
    } while (unusedImages.isEmpty ||
        DateUtils.isSameDay(
            unusedImages[0].createDateTime, unusedImages.last.createDateTime));

    if (unusedImages.isEmpty) return;

    DateTime oldestDay = unusedImages.last.createDateTime;

    while (!DateUtils.isSameDay(oldestDay, unusedImages[0].createDateTime)) {
      List<AssetEntity> dateImages = [];
      DateTime currentDate = unusedImages[0].createDateTime;

      while (unusedImages.isNotEmpty &&
          DateUtils.isSameDay(currentDate, unusedImages[0].createDateTime)) {
        dateImages.add(unusedImages.removeAt(0));
      }

      String dateText = currentDate.year == DateTime.now().year
          ? "${monthAbrev[currentDate.month]} ${currentDate.day + 1}"
          : "${currentDate.year} ${monthAbrev[currentDate.month]} ${currentDate.day + 1}";

      chunksByDate.add(Column(
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
              children: dateImages.asMap().entries.map((entry) {
                int ind = totalLoaded + entry.key;
                return imageWidget(
                    () => {_onTapImage(entry.value, ind)},
                    entry.value,
                    selectionMode
                        ? selected.contains(entry.value.id)
                            ? ImageWidgetStatus.selected
                            : ImageWidgetStatus.unselected
                        : ImageWidgetStatus.normal,
                    toggleSelection);
              }).toList())
        ],
      ));

      totalLoaded += dateImages.length;
    }
    setState(() {});
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

  void _onTapImage(AssetEntity image, int index) async {
    if (image.type == AssetType.image) {
      int imageIdx = images.indexOf(image);

      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePageWidget(
              images: images,
              imageTotal: images.length,
              index: imageIdx,
              eventController: eventController,
            ),
          ));
    } else if (image.type == AssetType.video) {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPageWidget(
              video: image,
              eventController: eventController,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scroll) {
                  final scrollPixels =
                      scroll.metrics.pixels / scroll.metrics.maxScrollExtent;

                  if (scrollPixels > 0.6) loadMoreDates();
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
                      Navigator.pop(context);
                      return true;
                    },
                    child: SafeArea(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(30, 20, 10, 0),
                              child: Row(
                                children: [
                                  Text(
                                    'PICTURES',
                                    style:
                                        mainTextStyle(TextStyleType.pageTitle),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.search))
                                ],
                              )),
                          // Album Grid
                          Expanded(
                            child: CustomScrollView(
                                primary: false,
                                slivers: <Widget>[
                                  SliverPadding(
                                      padding: const EdgeInsets.all(5),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                          return chunksByDate[index];
                                        }, childCount: chunksByDate.length),
                                      )),
                                ]),
                          )
                        ]))))));
  }
}
