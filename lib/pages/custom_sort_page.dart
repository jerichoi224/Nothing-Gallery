import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/model/model.dart';

@immutable
class CustomSortPage extends StatefulWidget {
  const CustomSortPage({super.key});

  @override
  State createState() => _CustomSortPageState();
}

class _CustomSortPageState extends State<CustomSortPage> {
  int albumsCol = 2;
  List<AlbumInfo> albums = [];

  @override
  void initState() {
    super.initState();
    albumsCol = sharedPref.get(SharedPrefKeys.albumsColCount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlbumInfoList albumInfoList =
          Provider.of<AlbumInfoList>(context, listen: false);
      AppStatus appStatus = Provider.of<AppStatus>(context, listen: false);

      List<AlbumInfo> prevList = List<AlbumInfo>.from(albumInfoList.albums);
      List<String> customOrder = appStatus.customSorting;
      albums.clear();

      for (String id in customOrder) {
        int idx = prevList.indexWhere((album) => album.pathEntity.id == id);
        if (idx == -1) continue;
        AlbumInfo album = prevList.removeAt(idx);
        albums.add(album);
      }
      albums = List.from(albums)..addAll(prevList);
      albums.removeWhere(
          (album) => appStatus.hiddenAblums.contains(album.pathEntity.id));
      setState(() {});
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = albums.removeAt(oldIndex);
      albums.insert(newIndex, item);
    });
    Provider.of<AppStatus>(context, listen: false)
        .setCustomSorting(albums.map((e) => e.pathEntity.id).toList());
  }

  Future<void> showHelpDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Custom Sort',
                style: mainTextStyle(TextStyleType.alertTitle)),
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                            "You can hold and drag albums to sort them in the order you'd like. The order will be automatically saved when changed.",
                            style: mainTextStyle(
                                TextStyleType.sortHelpDialogDescription)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("New albums will be appended to the end.",
                            style: mainTextStyle(
                                TextStyleType.sortHelpDialogDescription)),
                      ),
                      const SizedBox(height: 12),
                      Center(
                          child: DialogBottomButton(
                              text: 'Close',
                              onTap: () => {
                                    if (Navigator.canPop(context))
                                      {Navigator.pop(context)}
                                  },
                              style: mainTextStyle(TextStyleType.creditsClose)))
                    ],
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
                body: SafeArea(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 25),
                      child: Row(
                        children: [
                          Text(
                            'Custom Sort Order',
                            style: mainTextStyle(TextStyleType.pageTitle),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                showHelpDialog();
                              },
                              icon: const Icon(
                                Icons.help_outline_rounded,
                                size: 22,
                              ))
                        ],
                      )),
                  Expanded(
                      child: ReorderableGridView.count(
                          onReorder: _onReorder,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          crossAxisCount: albumsCol,
                          childAspectRatio: 0.85,
                          children: albums
                              .map((albumInfo) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      key: ValueKey(albumInfo.pathEntity.id),
                                      children: [
                                        ThumbnailWidget(
                                            asset: albumInfo.thumbnailAsset,
                                            radius: 8.0,
                                            isOriginal: true),
                                        Padding(
                                          padding: albumsCol == 2
                                              ? const EdgeInsets.fromLTRB(
                                                  10, 5, 0, 0)
                                              : const EdgeInsets.fromLTRB(
                                                  5, 5, 0, 0),
                                          child: Text(
                                            "${albumInfo.pathEntity.name.toUpperCase()} (${albumInfo.assetCount})",
                                            overflow: TextOverflow.ellipsis,
                                            style: mainTextStyle(albumsCol == 2
                                                ? TextStyleType.albumTitle2
                                                : TextStyleType.albumTitle3),
                                          ),
                                        ),
                                      ]))
                              .toList())),
                ])))));
  }
}
