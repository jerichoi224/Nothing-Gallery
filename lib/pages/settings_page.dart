import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/constants/settings_pref.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  bool initialIsTimeline = false;
  bool pinShortcuts = false;
  double rowHeight = 50;
  String version = "";
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  void getInfo() async {
    initialIsTimeline = sharedPref.get(SharedPrefKeys.initialScreen) ==
        InitialScreen.timeline.tabIndex;
    pinShortcuts = sharedPref.get(SharedPrefKeys.pinShortcuts);
    setState(() {});

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = "v ${packageInfo.version}";
      });
    });
  }

  Widget uiInitialScreen() {
    return SizedBox(
        height: rowHeight,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Row(
              children: [
                Text(
                  "Show Timeline on Start",
                  style: mainTextStyle(TextStyleType.settingsMenu),
                ),
                const Spacer(),
                Switch(
                    activeColor: Colors.red,
                    activeTrackColor: Colors.white,
                    value: initialIsTimeline,
                    onChanged: (onChanged) {
                      sharedPref.set(
                          SharedPrefKeys.initialScreen,
                          onChanged
                              ? InitialScreen.timeline.tabIndex
                              : InitialScreen.albums.tabIndex);
                      setState(() {
                        initialIsTimeline = onChanged;
                      });
                    }),
              ],
            )));
  }

  Widget pinButtons() {
    return SizedBox(
        height: rowHeight,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Row(
              children: [
                Text(
                  "Pin Favorites/Videos to Top",
                  style: mainTextStyle(TextStyleType.settingsMenu),
                ),
                const Spacer(),
                Switch(
                    activeColor: Colors.red,
                    activeTrackColor: Colors.white,
                    value: pinShortcuts,
                    onChanged: (onChanged) {
                      sharedPref.set(SharedPrefKeys.pinShortcuts, onChanged);
                      eventController.sink
                          .add(Event(EventType.settingsChanged, null));

                      setState(() {
                        pinShortcuts = onChanged;
                      });
                    }),
              ],
            )));
  }

  Widget license() {
    return InkWell(
        onTap: () {},
        child: SizedBox(
            height: rowHeight,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                child: Row(
                  children: [
                    Text(
                      "License",
                      style: mainTextStyle(TextStyleType.settingsMenu),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                    )
                  ],
                ))));
  }

  Widget credits() {
    return InkWell(
        onTap: () {},
        child: SizedBox(
            height: rowHeight,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                child: Row(
                  children: [
                    Text(
                      "Credits",
                      style: mainTextStyle(TextStyleType.settingsMenu),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                    )
                  ],
                ))));
  }

  Widget versionInfo() {
    return SizedBox(
        height: rowHeight,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
            child: Row(
              children: [
                Text(
                  "Version",
                  style: mainTextStyle(TextStyleType.settingsMenu),
                ),
                const Spacer(),
                Text(
                  version,
                  style: mainTextStyle(TextStyleType.settingsFineText),
                ),
              ],
            )));
  }

  Widget settingsWrapper(Widget child) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(body: SafeArea(child: child)));
  }

  Widget settingCategory(String text) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
        child: Text(
          text,
          style: mainTextStyle(TextStyleType.settingCategory),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return settingsWrapper(Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
            child: Text(
              'SETTINGS',
              style: mainTextStyle(TextStyleType.settingTitle),
            ),
          ),
        ],
      ),
      SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    settingCategory("UI/UX"),
                    const SizedBox(height: 8),
                    uiInitialScreen(),
                    const SizedBox(height: 8),
                    pinButtons(),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    settingCategory("ABOUT"),
                    const SizedBox(height: 8),
                    versionInfo(),
                    credits(),
                    license(),
                  ])))
    ]));
  }
}
