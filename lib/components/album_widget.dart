import 'package:flutter/material.dart';
import 'package:nothing_gallery/constants/album_widget_menu.dart';

import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/util/util.dart';
import 'package:provider/provider.dart';

class AlbumWidget extends StatelessWidget {
  const AlbumWidget({super.key, required this.albumInfo, required this.numCol});

  final AlbumInfo albumInfo;
  final double radius = 8.0;
  final int numCol;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(albumInfo.pathEntity.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            ThumbnailWidget(
                asset: albumInfo.thumbnailAsset,
                radius: radius,
                isOriginal: true),
            Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(radius))),
                      onTap: () {
                        openAlbum(context, albumInfo);
                      },
                    ),
                    onLongPressStart: (details) async {
                      final offset = details.globalPosition;
                      showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy,
                            MediaQuery.of(context).size.width - offset.dx,
                            MediaQuery.of(context).size.height - offset.dy,
                          ),
                          items: AlbumWidgetMenu.values
                              .map((item) => PopupMenuItem<AlbumWidgetMenu>(
                                    value: item,
                                    onTap: () {
                                      if (item == AlbumWidgetMenu.hideAlbum) {
                                        Provider.of<AppStatus>(context,
                                                listen: false)
                                            .addHiddenAblum(
                                                [albumInfo.pathEntity.id]);
                                      }
                                    },
                                    child: Text(
                                      item.text,
                                      style: mainTextStyle(
                                          TextStyleType.widgetMenuText),
                                    ),
                                  ))
                              .toList());
                    },
                  )),
            ),
          ],
        ),
        Padding(
          padding: numCol == 2
              ? const EdgeInsets.fromLTRB(10, 5, 0, 0)
              : const EdgeInsets.fromLTRB(5, 5, 0, 0),
          child: Text(
            "${albumInfo.pathEntity.name.toUpperCase()} (${albumInfo.assetCount})",
            overflow: TextOverflow.ellipsis,
            style: mainTextStyle(numCol == 2
                ? TextStyleType.albumTitle2
                : TextStyleType.albumTitle3),
          ),
        ),
      ],
    );
  }
}
