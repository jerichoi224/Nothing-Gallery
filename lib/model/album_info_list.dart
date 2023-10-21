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
  late AlbumInfo _recent;
  bool _isRefreshing = false;

  List<AlbumInfo> get albums =>
      _albums.where((album) => !album.pathEntity.isAll).toList();

  AlbumInfo? get recent => _recent;

  AlbumInfo getAlbum(String id) {
    return _albums.firstWhere((album) => album.pathEntity.id == id);
  }

  Future<void> refreshRecent() async {
    if (recent == null) return;
    List<AlbumInfo> updatedAlbums =
        await getCurrentAlbumStates([recent!.pathEntity.id]);
    if (updatedAlbums.isEmpty) return;

    _recent.pathEntity = updatedAlbums[0].pathEntity;
    _recent.thumbnailAsset = updatedAlbums[0].thumbnailAsset;
    _recent.preloadImages = updatedAlbums[0].preloadImages;
    _recent.assetCount = updatedAlbums[0].assetCount;
  }

  Future<void> refreshAlbums() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _albums.clear();
    addAlbum(await getCurrentAlbumStates([]));
    _recent = _albums.firstWhere((album) => album.pathEntity.isAll);

    _isRefreshing = false;
  }

  Future<void> changeAlbumThumbnail(AlbumInfo album, String? id) async {
    if (id == null) {
      album.thumbnailAsset = album.preloadImages[0];
    } else {
      AssetEntity? newThumbnail = await AssetEntity.fromId(id);
      if (newThumbnail == null) return;
      album.thumbnailAsset = newThumbnail;
    }
    notifyListeners();
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
}
