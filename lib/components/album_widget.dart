import 'package:flutter/material.dart';

import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/util/util.dart';

class AlbumWidget extends StatelessWidget {
  const AlbumWidget({super.key, required this.albumInfo});

  final AlbumInfo albumInfo;
  final double radius = 8.0;

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
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(radius))),
                  onTap: () {
                    openAlbum(context, albumInfo);
                  },
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
          child: Text(
            "${albumInfo.pathEntity.name.toUpperCase()} (${albumInfo.assetCount})",
            style: mainTextStyle(TextStyleType.albumTitle),
          ),
        ),
      ],
    );
  }
}
