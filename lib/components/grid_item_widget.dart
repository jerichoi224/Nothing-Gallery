import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/model/model.dart';

class GridItemWidget extends StatelessWidget {
  const GridItemWidget(
      {super.key,
      required this.context,
      required this.asset,
      required this.favoritePage,
      required this.thumbnailSelection});

  final BuildContext context;
  final AssetEntity asset;
  final bool favoritePage;
  final bool thumbnailSelection;

  final double radius = 2;

  void toggleSelection(ImageSelection imageSelection) {
    if (imageSelection.selectedIds.contains(asset.id)) {
      imageSelection.removeSelection([asset.id]);
    } else {
      imageSelection.addSelection([asset.id]);
    }
  }

  void onTap(ImageSelection imageSelection) async {
    if (thumbnailSelection) {
      Navigator.pop(context, asset.id);
      return;
    } else if (imageSelection.selectionMode) {
      toggleSelection(imageSelection);
    } else {
      if (asset.type == AssetType.image) {
        eventController.sink.add(Event(EventType.pictureOpen, asset));
      } else if (asset.type == AssetType.video) {
        eventController.sink.add(Event(EventType.videoOpen, asset));
      }
    }
  }

  void onLongPress(ImageSelection imageSelection) {
    if (thumbnailSelection) return;

    toggleSelection(imageSelection);
    if (!imageSelection.selectionMode) {
      imageSelection.startSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    String duration = '';

    if (asset.type == AssetType.video) {
      duration =
          asset.videoDuration.toString().split('.').first.padLeft(8, "0");
      if (duration.startsWith('00:')) {
        duration = duration.substring(3);
      }
    }

    return Consumer<ImageSelection>(builder: (context, imageSelection, child) {
      ImageWidgetStatus status = ImageWidgetStatus.normal;
      if (imageSelection.selectionMode) {
        status = imageSelection.selectedIds.contains(asset.id)
            ? ImageWidgetStatus.selected
            : ImageWidgetStatus.unselected;
      }

      return Stack(
        children: <Widget>[
          Hero(
              tag: asset.id,
              child: ThumbnailWidget(
                  asset: asset, radius: radius, isOriginal: false)),
          Positioned.fill(
            child: Material(
              color: status == ImageWidgetStatus.selected
                  ? Colors.black38
                  : Colors.transparent,
              child: Consumer<AppStatus>(builder: (context, appStatus, child) {
                return InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(radius))),
                  onTap: () {
                    if (!appStatus.loading) onTap(imageSelection);
                  },
                  onLongPress: () {
                    if (!appStatus.loading) onLongPress(imageSelection);
                  },
                );
              }),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  //** video duration (Top Left) **//
                  asset.type == AssetType.video
                      ? Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(2, 2, 0, 0),
                              child: Icon(
                                Icons.play_circle_rounded,
                                size: 18,
                              ),
                            ),
                            Text(" $duration",
                                style:
                                    mainTextStyle(TextStyleType.videoDuration))
                          ],
                        )
                      : Container(),
                  const Spacer(),
                  //** selection status (Top right) **//
                  status == ImageWidgetStatus.normal
                      ? Container()
                      : Icon(
                          status == ImageWidgetStatus.selected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 22,
                          color: status == ImageWidgetStatus.selected
                              ? Colors.grey.shade200
                              : Colors.grey.shade500,
                        ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Consumer<AppStatus>(builder: (context, appStatus, child) {
                    //** favorite (Bottom left) **//
                    if (!favoritePage &&
                        appStatus.favoriteIds.contains(asset.id)) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(Icons.favorite_rounded,
                                size: 20, color: Colors.red.shade400),
                          )
                        ],
                      );
                    }
                    return Container();
                  }),
                  const Spacer()
                ],
              )
            ],
          )
        ],
      );
    });
  }
}
