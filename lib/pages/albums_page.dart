import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/util/util.dart';

@immutable
class AlbumsWidget extends StatefulWidget {
  const AlbumsWidget({super.key});

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends LifecycleListenerState<AlbumsWidget>
    with AutomaticKeepAliveClientMixin {
  bool pinShortcuts = false;
  StreamSubscription? eventSubscription;
  SortOption sortOption = SortOption.recent;

  @override
  void initState() {
    super.initState();
    setState(() {
      sortOption = SortOption.values.firstWhere(
          (option) => option.id == sharedPref.get(SharedPrefKeys.sortOption));
      pinShortcuts = sharedPref.get(SharedPrefKeys.pinShortcuts);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final albumInfoList = Provider.of<AlbumInfoList>(context, listen: false);
      eventSubscription =
          eventController.stream.asBroadcastStream().listen((event) {
        switch (validateEventType(event)) {
          case EventType.settingsChanged:
            setState(() {
              pinShortcuts = sharedPref.get(SharedPrefKeys.pinShortcuts);
            });
            break;
          case EventType.assetDeleted:
          case EventType.assetMoved:
            albumInfoList.refreshAlbums();
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

  List<Widget> shortcuts() {
    return [
      Consumer<AppStatus>(builder: (context, appStatus, child) {
        return WideIconButton(
            text: "FAVORITES",
            hideIcon: false,
            iconData: appStatus.favoriteIds.isEmpty
                ? Icons.favorite_border_rounded
                : Icons.favorite_rounded,
            onTapHandler: () {
              if (appStatus.favoriteIds.isEmpty) {
                Fluttertoast.showToast(
                  msg: "No favorites were found.",
                  toastLength: Toast.LENGTH_SHORT,
                );
              } else {
                openFavoritePage(context);
              }
            });
      }),
      WideIconButton(
        text: "VIDEOS",
        hideIcon: false,
        iconData: Icons.video_library_rounded,
        onTapHandler: () {
          openVideoPage(context);
        },
      )
    ];
  }

  Widget sortMenu() {
    return PopupMenuButton<SortOption>(
        tooltip: '',
        offset: const Offset(0, 40),
        color: Colors.black,
        onSelected: (SortOption option) {
          sharedPref.set(SharedPrefKeys.sortOption, option.id);
          setState(() {
            sortOption = option;
          });
        },
        child: const InkWell(
          child: Icon(
            Icons.filter_list_rounded,
            size: 26,
          ),
        ),
        itemBuilder: (BuildContext context) {
          return [
            for (final value in SortOption.values)
              PopupMenuItem(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      value.text,
                      textAlign: TextAlign.center,
                      style: mainTextStyle(TextStyleType.popUpMenu),
                    ),
                  ))
          ];
        });
  }

  List<AlbumInfo> sortAlbums(List<AlbumInfo> albums) {
    switch (sortOption) {
      case SortOption.nameDescend:
        albums.sort((a, b) => b.pathEntity.name.compareTo(a.pathEntity.name));
        break;
      case SortOption.nameAscend:
        albums.sort((b, a) => b.pathEntity.name.compareTo(a.pathEntity.name));
        break;
      case SortOption.old:
        albums.sort((b, a) =>
            b.preloadImages[0].createDateTime.millisecondsSinceEpoch.compareTo(
                a.preloadImages[0].createDateTime.millisecondsSinceEpoch));
        break;
      case SortOption.recent:
      default:
        albums.sort((a, b) =>
            b.preloadImages[0].createDateTime.millisecondsSinceEpoch.compareTo(
                a.preloadImages[0].createDateTime.millisecondsSinceEpoch));
    }
    return albums;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(body: SafeArea(child:
            Consumer<AlbumInfoList>(builder: (context, albumInfoList, child) {
          List<AlbumInfo> albums = sortAlbums(albumInfoList.albums);

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: [
                        Text(
                          'ALBUMS',
                          style: mainTextStyle(TextStyleType.pageTitle),
                        ),
                        const Spacer(),
                        sortMenu()
                      ],
                    )),
                pinShortcuts
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          shrinkWrap: true,
                          children: shortcuts(),
                        ),
                      )
                    : Container(),
                Expanded(
                    child: RefreshIndicator(
                        color: Colors.red,
                        onRefresh: () async {
                          await albumInfoList.refreshAlbums();
                          return;
                        },
                        child: CustomScrollView(
                          primary: false,
                          slivers: <Widget>[
                            SliverPadding(
                                padding: pinShortcuts
                                    ? const EdgeInsets.all(0)
                                    : const EdgeInsets.fromLTRB(10, 20, 10, 10),
                                sliver: SliverGrid.count(
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.5,
                                    children: pinShortcuts ? [] : shortcuts())),
                            SliverPadding(
                                padding: const EdgeInsets.all(10),
                                sliver: SliverGrid.count(
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.85,
                                    children: albums
                                        .map((albumeInfo) =>
                                            AlbumWidget(albumInfo: albumeInfo))
                                        .toList())),
                          ],
                        )))
              ]);
        }))));
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
    Provider.of<AlbumInfoList>(context, listen: false).refreshAlbums();
    pinShortcuts = sharedPref.get(SharedPrefKeys.pinShortcuts);
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
