import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class AlbumInfo {
  AssetPathEntity album;
  AssetEntity thumbnailImage;
  int assetCount;

  AlbumInfo(this.album, this.thumbnailImage, this.assetCount);
}
