import 'package:flutter/material.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/components/left_widget_button.dart';
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

  Widget albumButtonListBuilder(ScrollController controller, bool copyFiles,
      List<AssetEntity> selectedAssets) {
    return Consumer<AlbumInfoList>(builder: (context, albumInfoList, child) {
      List<AlbumInfo> albumList = albumInfoList.albums;
      return ListView.builder(
        controller: controller,
        itemCount: albumList.length,
        itemBuilder: (_, index) {
          AlbumInfo albumInfo = albumList[index];
          return LeftWidgetButton(
              text:
                  "${albumInfo.pathEntity.name.toUpperCase()} (${albumInfo.assetCount})",
              widget: ThumbnailWidget(
                asset: albumInfo.thumbnailAsset,
                radius: 8.0,
                isOriginal: false,
              ),
              onTapHandler: () {
                moveCopyFiles(selectedAssets, copyFiles, albumInfo);
                Navigator.pop(context);
              });
        },
      );
    });
  }

  void copyMoveAssetsPanel(
      BuildContext context, bool copyFiles, List<AssetEntity> selectedAssets) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.2,
                maxChildSize: 0.75,
                builder: (_, controller) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          'Choose Album',
                          style: mainTextStyle(TextStyleType.moveToTitle),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: albumButtonListBuilder(
                              controller, copyFiles, selectedAssets),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                              backgroundColor: Colors.transparent),
                          child: Text('Cancel',
                              style: mainTextStyle(TextStyleType.buttonText)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

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
        Consumer<AppStatus>(builder: (context, appStatus, child) {
          return IconButton(
            onPressed: () async {
              List<String> deletedIds =
                  await onDelete(selectedAssets, imageSelection, useTrashBin);
              if (deletedIds.isNotEmpty) {
                appStatus.removeFavorite(deletedIds);
              }
            },
            icon: const Icon(Icons.delete),
          );
        }),
        showMore
            ? PopupMenuButton<SelectedImageMenu>(
                tooltip: '',
                offset: const Offset(0, 50),
                onSelected: (SelectedImageMenu item) {
                  switch (item) {
                    case SelectedImageMenu.copyTo:
                    case SelectedImageMenu.moveTo:
                      copyMoveAssetsPanel(context,
                          item == SelectedImageMenu.copyTo, selectedAssets);
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    for (final value in SelectedImageMenu.values)
                      PopupMenuItem(
                          value: value,
                          child: Text(
                            value.text,
                            style: mainTextStyle(TextStyleType.popUpMenu),
                          ))
                  ];
                })
            : Container(),
      ]);
    });
  }
}
