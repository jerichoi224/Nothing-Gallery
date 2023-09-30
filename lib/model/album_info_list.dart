import 'package:flutter/foundation.dart';
import 'package:nothing_gallery/util/loader_functions.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumInfo {
  AssetPathEntity pathEntity;
  AssetEntity thumbnailAsset;
  List<AssetEntity> preloadImages;
  int assetCount;

  AlbumInfo(this.pathEntity, this.thumbnailAsset, this.assetCount,
      this.preloadImages);
}

class AlbumInfoList extends ChangeNotifier {
  List<AlbumInfo> _albums = [];

  List<AlbumInfo> get albums =>
      _albums.where((album) => !album.pathEntity.isAll).toList();

  AlbumInfo get recent => _albums.firstWhere((album) => album.pathEntity.isAll);

  AlbumInfo getAlbum(String id) {
    return _albums.firstWhere((album) => album.pathEntity.id == id);
  }

  Future<void> refreshAlbums() async {
    _albums.clear();
    addAlbum(await getCurrentAlbumStates([]));
  }

  void addAlbum(List<AlbumInfo> albumInfoList) {
    _albums = List.from(_albums)..addAll(albumInfoList);
    _albums.sort((a, b) => b.thumbnailAsset.createDateTime
        .compareTo(a.thumbnailAsset.createDateTime));
    notifyListeners();
  }

  void removeAlbum(String id) {
    _albums.removeWhere((album) => album.pathEntity.id == id);
    notifyListeners();
  }

  Future<void> updateAlbum(AssetPathEntity album) async {
    List<AlbumInfo> albumList = (await getCurrentAlbumStates([album.id]));
    if (albumList.isEmpty) {
      removeAlbum(album.id);
    } else {
      AlbumInfo updatedAlbum = albumList.first;
      _albums.removeWhere(
          (album) => album.pathEntity.id == updatedAlbum.pathEntity.id);
      addAlbum([updatedAlbum]);
      notifyListeners();
    }
  }
}
