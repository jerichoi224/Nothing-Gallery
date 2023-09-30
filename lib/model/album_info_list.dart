import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumInfo {
  AssetPathEntity pathEntity;
  AssetEntity thumbnailAsset;
  int assetCount;

  AlbumInfo(this.pathEntity, this.thumbnailAsset, this.assetCount);
}

class AlbumInfoList extends ChangeNotifier {
  final List<AlbumInfo> _albums = [];

  List<AlbumInfo> get albums =>
      _albums.where((album) => !album.pathEntity.isAll).toList();

  AlbumInfo get recent => _albums.firstWhere((album) => album.pathEntity.isAll);

  void addAlbum(AlbumInfo albumInfo) {
    _albums.add(albumInfo);
  }

  void removeAlbum(String id) {
    albums.removeWhere((album) => album.pathEntity.id == id);
    notifyListeners();
  }
}
