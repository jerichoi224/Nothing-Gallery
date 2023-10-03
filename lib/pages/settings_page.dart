import 'package:flutter/material.dart';
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
  bool initialIsAlbum = false;

  @override
  void initState() {
    super.initState();

    initialIsAlbum = sharedPref.get(SharedPrefKeys.initialScreen) == 1;
  }

  Widget uiInitialScreen() {
    return Row(
      children: [
        Text(
          "Inital Screen",
          style: mainTextStyle(TextStyleType.settingsMenu),
        ),
        const Spacer(),
        Text(
          "Timeline",
          style: mainTextStyle(TextStyleType.settingsFineText),
        ),
        const SizedBox(
          width: 10,
        ),
        Switch(
            activeColor: Colors.red,
            activeTrackColor: Colors.white,
            value: initialIsAlbum,
            onChanged: (onChanged) {
              sharedPref.set(
                  SharedPrefKeys.initialScreen,
                  onChanged
                      ? InitialScreen.albums.tabIndex
                      : InitialScreen.timeline.tabIndex);
              setState(() {
                initialIsAlbum = onChanged;
              });
            }),
        const SizedBox(
          width: 10,
        ),
        Text(
          "Albums",
          style: mainTextStyle(TextStyleType.settingsFineText),
        ),
      ],
    );
  }

  Widget settingsWrapper(Widget child) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(body: SafeArea(child: child)));
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'UI/UX',
                      style: mainTextStyle(TextStyleType.settingCategory),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    uiInitialScreen(),
                    SizedBox(height: 8),
                  ])))
    ]));
  }
}
