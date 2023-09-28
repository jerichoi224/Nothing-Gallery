import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      Text(
                        'SETTINGS',
                        style: settingsTitleTextStyle(),
                      ),
                      Expanded(
                          child: Text(
                        'WIP',
                        style: settingsTitleTextStyle(),
                      ))
                    ])))));
  }
}
