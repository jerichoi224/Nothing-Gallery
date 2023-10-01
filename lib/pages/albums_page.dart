import 'package:flutter/material.dart';
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
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  Widget topButton(String text, IconData icon) {
    return Center(
        child: ClipRRect(
      child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(24, 28, 30, 1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () {},
                  customBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 28,
                      ),
                      const SizedBox(
                        height: double.infinity,
                        width: 16,
                      ),
                      Text(
                        text,
                        style: mainTextStyle(TextStyleType.buttonText),
                      )
                    ],
                  )))),
    ));
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
                        IconButton(
                            onPressed: () {
                              albumInfoList.refreshAlbums();
                            },
                            icon: const Icon(Icons.refresh)),
                        IconButton(
                            onPressed: () {}, icon: const Icon(Icons.search))
                      ],
                    )),
                // Album Grid
                Expanded(
                    child: CustomScrollView(
                  primary: false,
                  slivers: <Widget>[
                    SliverPadding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                        sliver: SliverGrid.count(
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            children: [
                              topButton(
                                "FAVORITE",
                                Icons.star_border_rounded,
                              ),
                              topButton("VIDEO", Icons.video_library_rounded),
                            ])),
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
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
