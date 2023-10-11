import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/util/util.dart';

class SingleItemBottomMenu extends StatelessWidget {
  const SingleItemBottomMenu(
      {super.key,
      required this.parentContext,
      required this.asset,
      required this.popOnDelete,
      required this.favoritesPage});

  final BuildContext parentContext;
  final AssetEntity asset;
  final bool popOnDelete;
  final bool favoritesPage;

  @override
  Widget build(BuildContext context) {
    bool useTrashbin = true;

    return Consumer<AppStatus>(builder: (context, appStatus, child) {
      bool isFavorite = appStatus.isFavorite(asset.id);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              onPressed: () {
                isFavorite
                    ? appStatus.removeFavorite([asset.id])
                    : appStatus.addFavorite([asset.id]);
              },
              icon: Icon(isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded)),
          IconButton(
              onPressed: () {
                shareFiles([asset]);
              },
              icon: const Icon(Icons.share)),
          IconButton(
              onPressed: () async {
                confirmDelete([asset], useTrashbin).then((deletedList) {
                  appStatus.removeFavorite(deletedList);
                  if (deletedList.isNotEmpty && popOnDelete) {
                    Navigator.pop(parentContext);
                  }
                });
              },
              icon: const Icon(Icons.delete)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      );
    });
  }
}
