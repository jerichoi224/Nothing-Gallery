import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:photo_manager/photo_manager.dart';

Future<List<AssetEntity>> loadAllImages() async {
  int total = await PhotoManager.getAssetCount();
  List<AssetEntity> pictures =
      await PhotoManager.getAssetListRange(start: 0, end: total);
  pictures.sort((a, b) => b.createDateTime.millisecondsSinceEpoch
      .compareTo(a.createDateTime.millisecondsSinceEpoch));
  return pictures;
}

Future<AlbumInfo> getAlbumInfo(AssetPathEntity album) async {
  int assetCount = await album.assetCountAsync;
  List<AssetEntity> images =
      await album.getAssetListRange(start: 0, end: assetCount);
  images.sort((a, b) => b.createDateTime.millisecondsSinceEpoch
      .compareTo(a.createDateTime.millisecondsSinceEpoch));

  return AlbumInfo(album, images, images[0], assetCount);
}
