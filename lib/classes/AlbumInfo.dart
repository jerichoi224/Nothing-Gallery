// ignore_for_file: file_names

import 'package:photo_manager/photo_manager.dart';

class AlbumInfo {
  AssetPathEntity album;
  AssetEntity thumbnailImage;
  int assetCount;
  List<AssetEntity> images;

  AlbumInfo(this.album, this.images, this.thumbnailImage, this.assetCount);
}
