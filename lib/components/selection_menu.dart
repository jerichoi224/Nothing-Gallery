import 'package:flutter/material.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/util.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/model/model.dart';

class SelectionMenuWidget extends StatelessWidget {
  const SelectionMenuWidget(
      {super.key, required this.assets, required this.showMore});

  final List<AssetEntity> assets;
  final bool showMore;
  @override
  Widget build(BuildContext context) {
    bool useTrashBin = sharedPref.get(SharedPrefKeys.useTrashBin);

    return Consumer<ImageSelection>(builder: (context, imageSelection, child) {
      List<AssetEntity> selectedAssets = assets
          .where((element) => imageSelection.selectedIds.contains(element.id))
          .toList();
      return Row(children: [
        IconButton(
          onPressed: () {
            shareFiles(selectedAssets);
          },
          icon: const Icon(Icons.share),
        ),
        IconButton(
          onPressed: () {
            onDelete(selectedAssets, imageSelection, useTrashBin);
          },
          icon: const Icon(Icons.delete),
        ),
        showMore
            ? PopupMenuButton<SelectedImageMenu>(
                tooltip: '',
                offset: const Offset(0, 50),
                onSelected: (SelectedImageMenu item) {},
                itemBuilder: (BuildContext context) {
                  return [
                    for (final value in SelectedImageMenu.values)
                      PopupMenuItem(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              value.text,
                              style: mainTextStyle(TextStyleType.popUpMenu),
                            ),
                          ))
                  ];
                })
            : Container(),
      ]);
    });
  }
}
