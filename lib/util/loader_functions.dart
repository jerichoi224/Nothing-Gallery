import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:photo_manager/photo_manager.dart';

Future<List<AssetEntity>> loadAssets(AssetPathEntity album, int page,
    {int size = 40}) async {
  final images = await album.getAssetListPaged(
    page: page,
    size: size,
  );
  return images;
}

Future<List<AlbumInfo>> getInitialAlbums() async {
  List<AlbumInfo> albums = [];

  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
  for (AssetPathEntity path in paths) {
    albums.add(await getInitialAlbumInfo(path));
  }
  return albums;
}

Future<AlbumInfo> getInitialAlbumInfo(AssetPathEntity album) async {
  int assetCount = await album.assetCountAsync;

  List<AssetEntity> images = await album.getAssetListRange(start: 0, end: 80);
  images.sort((a, b) => b.createDateTime.millisecondsSinceEpoch
      .compareTo(a.createDateTime.millisecondsSinceEpoch));

  // TODO: Store Thumbnail Image by ID
  // final AssetEntity? asset = await AssetEntity.fromId(id);

  return AlbumInfo(album, images, images[0], assetCount);
}