import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:nothing_gallery/model/model.dart';

Future<List<AssetEntity>> loadAssets(AssetPathEntity album, int page,
    {int size = 40}) async {
  final images = await album.getAssetListPaged(
    page: page,
    size: size,
  );
  return images;
}

Future<List<AlbumInfo>> getCurrentAlbumStates(List<String> ids) async {
  List<AlbumInfo> albums = [];

  List<AssetPathEntity> pathEntities = await PhotoManager.getAssetPathList();
  if (ids.isNotEmpty) {
    pathEntities.removeWhere((entity) => !ids.contains(entity.id));
  }
  Map<String, dynamic> customThumbnails =
      sharedPref.get(SharedPrefKeys.customThumbnails);

  Map<String, dynamic> newMap = Map<String, dynamic>.from(customThumbnails);

  for (AssetPathEntity path in pathEntities) {
    AlbumInfo album = await getInitialAlbumInfo(path);

    if (customThumbnails.containsKey(album.pathEntity.id)) {
      String id = customThumbnails[album.pathEntity.id];
      AssetEntity? thumbnail = await AssetEntity.fromId(id);
      if (thumbnail != null) {
        album.thumbnailAsset = thumbnail;
      } else {
        newMap.remove(album.pathEntity.id);
      }
    }
    albums.add(album);
  }
  sharedPref.set(SharedPrefKeys.customThumbnails, newMap);
  return albums;
}

Future<AlbumInfo> getInitialAlbumInfo(AssetPathEntity album) async {
  int assetCount = await album.assetCountAsync;

  List<AssetEntity> images = await album.getAssetListRange(start: 0, end: 8);

  images.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
  return AlbumInfo(album, images[0], assetCount, images);
}
