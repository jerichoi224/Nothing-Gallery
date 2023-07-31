import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/constants/eventType.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/pages/albumsPage.dart';
import 'package:nothing_gallery/pages/picturesPage.dart';
import 'package:photo_manager/photo_manager.dart';

//ignore: must_be_immutable
class HomeWidget extends StatefulWidget {
  final BuildContext parentCtx;
  late SharedPref sharedPref;
  late List<AssetEntity> pictures;
  late List<AlbumInfo> albums;

  HomeWidget(
      {super.key,
      required this.parentCtx,
      required this.sharedPref,
      required this.pictures,
      required this.albums});

  @override
  State<HomeWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeWidget> {
  StreamController<Event> eventController = StreamController<Event>.broadcast();
  StreamSubscription? eventSubscription;
  List<AssetEntity> pictures = [];
  List<AlbumInfo> albums = [];

  final List<Widget> screens = [];

  bool ready = false;
  String? username = "";

  @override
  void initState() {
    super.initState();
    pictures = widget.pictures;
    albums = widget.albums;

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      if (event.runtimeType == Event) {
        if (event.eventType == EventType.pictureDeleted) {
          if (event.details != null && event.details.runtimeType == String) {
            pictures.removeWhere((element) => element.id == event.details);
            setState(() {});
          }
        } else {}
      }
    });
  }

  @override
  void dispose() {
    eventController.close();
    eventSubscription?.cancel();
    super.dispose();
  }

  List<Widget> _children() => [
        PicturesWidget(
          pictures: widget.pictures,
          eventController: eventController,
        ),
        AlbumsWidget(
            sharedPref: widget.sharedPref,
            albums: widget.albums,
            eventController: eventController)
      ];

  static const List<Tab> _tabs = [
    Tab(text: "PICTURES"),
    Tab(text: "ALBUMS"),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return MediaQuery(
        data: mediaQueryData.copyWith(textScaleFactor: 1.0),
        child: DefaultTabController(
          initialIndex: 1,
          length: 2,
          child: Scaffold(
            bottomNavigationBar: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TabBar(
                        indicatorColor: Colors.transparent,
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white12;
                            }
                            return Colors.transparent;
                          },
                        ),
                        labelStyle: bottomNavTextStyle(),
                        unselectedLabelStyle: bottomNavTextStyle(),
                        tabs: _tabs,
                        labelColor: Colors.red,
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                            height: 50,
                            child: InkWell(
                                child: const Icon(
                                  Icons.list,
                                  size: 26,
                                ),
                                onTap: () {}))),
                  ],
                )),
            body: TabBarView(children: _children()),
          ),
        ));
  }
}
