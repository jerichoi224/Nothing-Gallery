import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/model/album_info_list.dart';
import 'package:nothing_gallery/pages/pages.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/util/util.dart';
import 'package:provider/provider.dart';

@immutable
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final albumInfoList = Provider.of<AlbumInfoList>(context, listen: false);
      albumInfoList.refreshAlbums();
    });

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      if (event.runtimeType == Event) {
        if (event.eventType == EventType.assetDeleted) {
          if (event.details != null && event.details.runtimeType == String) {
            setState(() {});
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

  List<Widget> tabPages() => [const PicturesWidget(), const AlbumsWidget()];

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
