import 'package:photo_manager/photo_manager.dart';

Future<List<AssetEntity>> loadImages(AssetPathEntity album, int page,
    {int size = 40}) async {
  final images = await album.getAssetListPaged(
    page: page,
    size: size,
  );
  return images;
}
