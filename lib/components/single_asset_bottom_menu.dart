import 'package:flutter/material.dart';
import 'package:nothing_gallery/util/util.dart';
import 'package:photo_manager/photo_manager.dart';

class SingleItemBottomMenu extends StatelessWidget {
  const SingleItemBottomMenu(
      {super.key,
      required this.parentContext,
      required this.asset,
      required this.popOnDelete});

  final BuildContext parentContext;
  final AssetEntity asset;
  final bool popOnDelete;

  @override
  Widget build(BuildContext context) {
    bool useTrashbin = true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            onPressed: () {}, icon: const Icon(Icons.favorite_border_outlined)),
        IconButton(
            onPressed: () {
              shareFiles([asset]);
            },
            icon: const Icon(Icons.share)),
        IconButton(
            onPressed: () async {
              confirmDelete([asset], useTrashbin).then((deletedList) {
                if (deletedList.isNotEmpty && popOnDelete) {
                  Navigator.pop(parentContext);
                }
              });
            },
            icon: const Icon(Icons.delete)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }
}
