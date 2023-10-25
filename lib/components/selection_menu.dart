import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/util.dart';

import 'package:nothing_gallery/model/model.dart';

class SelectionMenu extends StatefulWidget {
  const SelectionMenu(
      {super.key,
      required this.assets,
      required this.showMore,
      required this.currentAlbum});

  final List<AssetEntity> assets;
  final bool showMore;
  final AssetPathEntity? currentAlbum;

  @override
  State createState() => _SelectionMenuState();
}

class _SelectionMenuState extends State<SelectionMenu>
    with SingleTickerProviderStateMixin {
  int index = 0;

  Future<String> createNewFolder(BuildContext context) async {
    final TextEditingController textController = TextEditingController();

    String newFolderName = "";
    double radius = 8;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Create New Folder',
                style: mainTextStyle(TextStyleType.moveToTitle)),
            children: <Widget>[
              Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 6, 28, 12),
                  child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 16, 16, 16),
                        borderRadius: BorderRadius.circular(radius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintStyle:
                                mainTextStyle(TextStyleType.newFolderHint),
                            border: InputBorder.none,
                            hintText: 'Enter folder name',
                          ),
                        ),
                      )),
                ),
                Center(
                    child: DialogBottomButton(
                        text: 'Create',
                        onTap: () => {
                              newFolderName = textController.text,
                              if (Navigator.canPop(context))
                                {Navigator.pop(context)}
                            },
                        style: mainTextStyle(TextStyleType.creditsClose)))
              ])
            ],
          );
        });

    if (newFolderName.isEmpty) return newFolderName;

    String createFolderPath = "/storage/emulated/0/DCIM/$newFolderName/";
    final dir = Directory(createFolderPath);

    if ((await dir.exists())) {
    } else {
      await dir.create();
    }
    return createFolderPath;
  }

  Widget albumButtonListBuilder(ScrollController controller, bool copyFiles,
      List<AssetEntity> selectedAssets) {
    double radius = 8.0;

    return Consumer<AlbumInfoList>(builder: (context, albumInfoList, child) {
      List<AlbumInfo> albumList = [...albumInfoList.albums];

      if (albumList.isNotEmpty && widget.currentAlbum != null) {
        AlbumInfo currentAlbum = albumList.firstWhere(
            (album) => album.pathEntity.id == widget.currentAlbum!.id);

        albumList.remove(currentAlbum);
        albumList.insert(0, currentAlbum);
      }
      return ListView.builder(
        controller: controller,
        itemCount: albumList.length,
        itemBuilder: (_, index) {
          AlbumInfo albumInfo = albumList[index];
          bool createFolder = index == 0;
          return LeftWidgetButton(
              text: createFolder
                  ? "Create New Folder"
                  : "${albumInfo.pathEntity.name.toUpperCase()} (${albumInfo.assetCount})",
              widget: createFolder
                  ? AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Container(
                              color: const Color.fromARGB(255, 32, 32, 32),
                              child: const Center(child: Icon(Icons.add)))))
                  : ThumbnailWidget(
                      asset: albumInfo.thumbnailAsset,
                      radius: radius,
                      isOriginal: false,
                    ),
              onTapHandler: () async {
                final appStatus =
                    Provider.of<AppStatus>(context, listen: false);
                final imageSelection =
                    Provider.of<ImageSelection>(context, listen: false);

                String destinationPath = "";

                if (createFolder) {
                  destinationPath =
                      await createNewFolder(context).then((value) {
                    if (value.isNotEmpty && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    return value;
                  });
                  if (destinationPath.isEmpty) return;
                } else {
                  File? destinationFile =
                      await albumInfo.thumbnailAsset.file.then((value) {
                    if (value != null && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    return value;
                  });
                  if (destinationFile == null) {
                    return;
                  }

                  destinationPath = destinationFile.path
                      .substring(0, destinationFile.path.lastIndexOf('/') + 1);
                }
                appStatus.setLoading(true);
                await moveCopyFiles(selectedAssets, copyFiles, destinationPath)
                    .then((files) {
                  appStatus.setLoading(false);
                  imageSelection.endSelection();

                  if (files.isNotEmpty) {
                    if (files.isNotEmpty) {
                      if (copyFiles) {
                        // eventController.sink.add(Event(EventType.assetCopied, movedFiles));
                      } else {
                        eventController.sink
                            .add(Event(EventType.assetMoved, files));
                      }
                    }
                  }
                });
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
                          topRight: Radius.circular(24.0)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        Text('Choose Album',
                            style: mainTextStyle(TextStyleType.moveToTitle)),
                        const SizedBox(height: 20),
                        Expanded(
                            child: albumButtonListBuilder(
                                controller, copyFiles, selectedAssets)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                surfaceTintColor: Colors.transparent,
                                backgroundColor: Colors.transparent),
                            child: Text('Cancel',
                                style: mainTextStyle(TextStyleType.buttonText)),
                            onPressed: () => Navigator.pop(context)),
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
      List<AssetEntity> selectedAssets = widget.assets
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
        widget.showMore
            ? PopupMenuButton<SelectedImageMenu>(
                tooltip: '',
                offset: const Offset(0, 50),
                onSelected: (SelectedImageMenu item) {
                  switch (item) {
                    // Can't read files that are copied for some reason..
                    // case SelectedImageMenu.copyTo:
                    case SelectedImageMenu.moveTo:
                      copyMoveAssetsPanel(context, false, selectedAssets);
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
