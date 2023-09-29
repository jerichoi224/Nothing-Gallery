import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/constants/eventType.dart';
import 'package:nothing_gallery/constants/home_page_enum.dart';
import 'package:nothing_gallery/pages/albumsPage.dart';
import 'package:nothing_gallery/pages/picturesPage.dart';
import 'package:nothing_gallery/util/navigation.dart';

@immutable
class HomeWidget extends StatefulWidget {
  final List<AlbumInfo> albums;

  const HomeWidget({super.key, required this.albums});

  @override
  State<HomeWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeWidget> {
  StreamSubscription? eventSubscription;

  static final List<Tab> _tabs =
      HomeTabMenu.values.map((tab) => Tab(text: tab.text)).toList();

  static const double navBarHeight = 50;

  @override
  void initState() {
    super.initState();

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      if (event.runtimeType == Event) {
        if (event.eventType == EventType.pictureDeleted) {
          if (event.details != null && event.details.runtimeType == String) {
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

  List<Widget> tabPages() =>
      [PicturesWidget(), AlbumsWidget(albums: widget.albums)];

  Widget homePopupMenu() {
    return PopupMenuButton<HomePopupMenu>(
        tooltip: '',
        onSelected: onHomePopupMenuSelected,
        child: const InkWell(
          child: Icon(
            Icons.list,
            size: 26,
          ),
        ),
        itemBuilder: (BuildContext context) {
          return [
            for (final value in HomePopupMenu.values)
              PopupMenuItem(
                value: value,
                child: Text(
                  value.text,
                  style: mainTextStyle(TextStyleType.popUpMenu),
                ),
              )
          ];
        });
  }

  void onHomePopupMenuSelected(HomePopupMenu item) {
    switch (item) {
      case HomePopupMenu.settings:
        openSettings(context);
        break;
      default:
        break;
    }
  }

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
                height: navBarHeight,
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
                        labelStyle: mainTextStyle(TextStyleType.navBar),
                        unselectedLabelStyle:
                            mainTextStyle(TextStyleType.navBar),
                        tabs: _tabs,
                        labelColor: Colors.red,
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                            height: navBarHeight, child: homePopupMenu())),
                  ],
                )),
            body: TabBarView(children: tabPages()),
          ),
        ));
  }
}
