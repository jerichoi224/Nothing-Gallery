import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

Future<List<String>> confirmDelete(BuildContext context,
    List<AssetEntity> deleteEntityList, bool useTrash) async {
  List<File> backups = [];
  if (useTrash) {
    for (var item in deleteEntityList) {
      File? backup = await moveToTrash(item);
      if (backup != null) backups.add(backup);
    }
  }

  List<String> result = await PhotoManager.editor
      .deleteWithIds(deleteEntityList.map((e) => e.id).toList());
  if (result.isEmpty) {
    print("Files not deleted. Removing Backup");
    for (var element in backups) {
      element.deleteSync();
    }
    return [];
  }
  return result;
}

Future<void> shareFiles(List<AssetEntity> images) async {
  List<String> paths = [];

  for (AssetEntity image in images) {
    File? file = await image.originFile;
    if (file != null) {
      paths.add(file.path);
    }
  }

  Share.shareXFiles(paths.map((path) => XFile(path)).toList());
}

Future<File?> moveToTrash(AssetEntity entity) async {
  Directory private = await getApplicationDocumentsDirectory();

  Uint8List? originBytes = await entity.originBytes;
  File? originFile = await entity.originFile;
  Directory trashDir = Directory("${private.path}/trash");

  if (!(await trashDir.exists())) {
    await trashDir.create();
  }

  if (originFile != null && originBytes != null) {
    Uint8List imageInUnit8List = originBytes;
    var lastSeparator = originFile.path.lastIndexOf(Platform.pathSeparator);

    File file = await File(
            '${trashDir.path}${originFile.path.substring(lastSeparator)}')
        .create();
    file.writeAsBytesSync(imageInUnit8List);
    return file;
  }
  return null;
}