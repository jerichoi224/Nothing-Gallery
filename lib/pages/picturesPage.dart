import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/constants/eventType.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

class PicturesWidget extends StatefulWidget {
  late List<AssetEntity> pictures;
  late StreamController eventController;

  PicturesWidget(
      {super.key, required this.pictures, required this.eventController});

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
    loadMoreDates();
    images = List.from(widget.pictures);
    images.removeWhere((element) => element.type != AssetType.image);

    eventSubscription =
        widget.eventController.stream.asBroadcastStream().listen((event) {
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
    return widget.pictures.sublist((currentPage - 1) * loadImageCount,
        min(currentPage * loadImageCount, widget.pictures.length));
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
              style: picturesDateTakenStyle(),
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
                  () => {_openImage(entry.value, ind)},
                  entry.value,
                );
              }).toList())
        ],
      ));

      totalLoaded += dateImages.length;
    }
    setState(() {});
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
  }

  @override
  Widget build(BuildContext context) {
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
                                style: pageTitleTextStyle(),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.search))
                            ],
                          )),
                      // Album Grid
                      Expanded(
                        child:
                            CustomScrollView(primary: false, slivers: <Widget>[
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
                    ])))));
  }
}
