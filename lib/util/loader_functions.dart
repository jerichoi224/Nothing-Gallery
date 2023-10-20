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
  for (AssetPathEntity path in pathEntities) {
    albums.add(await getInitialAlbumInfo(path));
  }
  return albums;
}

Future<AlbumInfo> getInitialAlbumInfo(AssetPathEntity album) async {
  int assetCount = await album.assetCountAsync;

  List<AssetEntity> images = await album.getAssetListRange(start: 0, end: 8);

  images.sort((a, b) => b.createDateTime.millisecondsSinceEpoch
      .compareTo(a.createDateTime.millisecondsSinceEpoch));

  return AlbumInfo(album, images[0], assetCount, images);
}
