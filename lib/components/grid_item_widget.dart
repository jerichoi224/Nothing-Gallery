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
  const GridItemWidget({
    super.key,
    required this.asset,
  });

  final AssetEntity asset;

  final double radius = 0;

  void toggleSelection(ImageSelection imageSelection) {
    if (imageSelection.selectedIds.contains(asset.id)) {
      imageSelection.removeSelection([asset.id]);
    } else {
      imageSelection.addSelection([asset.id]);
    }
  }

  void onTap(ImageSelection imageSelection) async {
    if (imageSelection.selectionMode) {
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

      return Hero(
          tag: asset.id,
          child: Stack(
            children: <Widget>[
              ThumbnailWidget(asset: asset, radius: radius, isOriginal: false),
              Positioned.fill(
                child: Material(
                  color: status == ImageWidgetStatus.selected
                      ? Colors.black38
                      : Colors.transparent,
                  child: InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(radius))),
                    onTap: () {
                      onTap(imageSelection);
                    },
                    onLongPress: () {
                      onLongPress(imageSelection);
                    },
                  ),
                ),
              ),

              //** video duration **//
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
                            style: mainTextStyle(TextStyleType.videoDuration))
                      ],
                    )
                  : Container(),

              //** selection status **//
              status == ImageWidgetStatus.normal
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          status == ImageWidgetStatus.selected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 22,
                          color: status == ImageWidgetStatus.selected
                              ? Colors.grey.shade200
                              : Colors.grey.shade500,
                        ),
                      ],
                    )
            ],
          ));
    });
  }
}
