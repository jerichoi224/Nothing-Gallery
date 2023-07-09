// ignore_for_file: file_names

import 'package:photo_manager/photo_manager.dart';

class AlbumInfo {
  AssetPathEntity album;
  AssetEntity thumbnailImage;
  int assetCount;

  AlbumInfo(this.album, this.thumbnailImage, this.assetCount);
}
