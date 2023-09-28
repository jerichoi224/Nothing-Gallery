import 'package:flutter/material.dart';
import 'package:nothing_gallery/pages/settingsPage.dart';

void openSettings(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ));
}
