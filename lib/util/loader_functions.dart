import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:photo_manager/photo_manager.dart';

Future<List<AlbumInfo>> getInitialAlbums() async {
  List<AlbumInfo> albums = [];

  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
  paths.removeWhere((element) => element.id == 'isAll'); // remove recent
  for (AssetPathEntity path in paths) {
    albums.add(await getInitialAlbumInfo(path));
  }
  return albums;
}

Future<AlbumInfo> getInitialAlbumInfo(AssetPathEntity album) async {
  int assetCount = await album.assetCountAsync;

  List<AssetEntity> images = await album.getAssetListRange(start: 0, end: 100);
  images.sort((a, b) => b.createDateTime.millisecondsSinceEpoch
      .compareTo(a.createDateTime.millisecondsSinceEpoch));

  // TODO: Store Thumbnail Image by ID
  // final AssetEntity? asset = await AssetEntity.fromId(id);

  return AlbumInfo(album, images, images[0], assetCount);
}
