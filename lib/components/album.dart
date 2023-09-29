import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/pages/image_grid_page.dart';
import 'package:nothing_gallery/style.dart';

class AlbumWidget extends StatelessWidget {
  const AlbumWidget({super.key, required this.albumInfo});

  final AlbumInfo albumInfo;
  final double radius = 8.0;

  void _openAlbum(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageGridWidget(
            album: albumInfo,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(albumInfo.album.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            imageThumbnailWidget(albumInfo.thumbnailImage, radius, true),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(radius))),
                  onTap: () {
                    _openAlbum(context);
                  },
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
          child: Text(
            "${albumInfo.album.name.toUpperCase()} (${albumInfo.assetCount})",
            style: mainTextStyle(TextStyleType.albumTitle),
          ),
        ),
      ],
    );
  }
}
