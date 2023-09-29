import 'package:flutter/material.dart';
import 'package:nothing_gallery/pages/settings_page.dart';

void openSettings(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ));
}
