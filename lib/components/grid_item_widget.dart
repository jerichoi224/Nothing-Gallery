import 'package:flutter/material.dart';
import 'package:nothing_gallery/components/image_thumbnail_widget.dart';
import 'package:nothing_gallery/constants/image_widget_status.dart';
import 'package:nothing_gallery/model/image_selection.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

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
        // TODO: eventController. Open Image (id)
      } else if (asset.type == AssetType.video) {
        // TODO: eventController. Open Video (id)
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
                            Icons.play_circle_outline,
                            size: 22,
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
                              ? Icons.check_circle_outline
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
