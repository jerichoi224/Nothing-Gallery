import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/util/util.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/model/model.dart';

@immutable
class AlbumsWidget extends StatefulWidget {
  const AlbumsWidget({super.key});

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends LifecycleListenerState<AlbumsWidget>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  bool pinShortcuts = false;
  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(body: SafeArea(child:
            Consumer<AlbumInfoList>(builder: (context, albumInfoList, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          'ALBUMS',
                          style: mainTextStyle(TextStyleType.pageTitle),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            albumInfoList.refreshAlbums();

                            _controller.forward().then((value) {
                              _controller.reset();
                            });
                          },
                          child: RotationTransition(
                            turns: Tween(begin: 0.0, end: 1.0)
                                .animate(_controller),
                            child: const Icon(Icons.refresh_rounded),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    )),
                pinShortcuts
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
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
                            children: albumInfoList.albums
                                .map((albumeInfo) =>
                                    AlbumWidget(albumInfo: albumeInfo))
                                .toList())),
                  ],
                ))
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
