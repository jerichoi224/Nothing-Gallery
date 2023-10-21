import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/dialog_bottom_button.dart';
import 'package:nothing_gallery/model/album_info_list.dart';
import 'package:nothing_gallery/model/app_status.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  bool initialIsTimeline = false;
  bool pinShortcuts = false;
  int numAlbumCol = 2;
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
    numAlbumCol = sharedPref.get(SharedPrefKeys.albumsColCount);
    setState(() {});

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = "v${packageInfo.version}";
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

  Widget albumColumnCount() {
    return SizedBox(
        height: rowHeight,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Row(
              children: [
                Text(
                  "Use 3 Columns For Albums",
                  style: mainTextStyle(TextStyleType.settingsMenu),
                ),
                const Spacer(),
                Switch(
                    activeColor: Colors.red,
                    activeTrackColor: Colors.white,
                    value: numAlbumCol == 3,
                    onChanged: (onChanged) {
                      numAlbumCol = onChanged ? 3 : 2;
                      sharedPref.set(
                          SharedPrefKeys.albumsColCount, numAlbumCol);
                      eventController.sink
                          .add(Event(EventType.settingsChanged, null));

                      setState(() {});
                    }),
              ],
            )));
  }

  Widget showHiddenAlbums() {
    return InkWell(
        onTap: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    scrollable: true,
                    contentPadding: const EdgeInsets.all(20),
                    title: Text('Hidden Albums',
                        style: mainTextStyle(TextStyleType.alertTitle)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Consumer<AppStatus>(
                                    builder: (context, appStatus, child) {
                                  List<String> hiddenAlbums =
                                      appStatus.hiddenAblums;

                                  if (hiddenAlbums.isEmpty) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(
                                          "You have no hidden albums.",
                                          style: mainTextStyle(TextStyleType
                                              .settingsPageDescription),
                                        ));
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: Provider.of<AlbumInfoList>(
                                            context,
                                            listen: false)
                                        .albums
                                        .where((album) => hiddenAlbums
                                            .contains(album.pathEntity.id))
                                        .map((album) => Row(
                                              children: [
                                                Text(
                                                  album.pathEntity.name
                                                      .toUpperCase(),
                                                  style: mainTextStyle(TextStyleType
                                                      .settingsPageDescription),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                    onPressed: () {
                                                      appStatus
                                                          .removeHiddenAlbum([
                                                        album.pathEntity.id
                                                      ]);
                                                    },
                                                    icon:
                                                        const Icon(Icons.close))
                                              ],
                                            ))
                                        .toList(),
                                  );
                                })),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        )));
              });
        },
        child: SizedBox(
            height: rowHeight,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                child: Row(
                  children: [
                    Text(
                      "Show Hidden Albums",
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

  Widget license() {
    return InkWell(
        onTap: () async {
          final Uri url = Uri.parse('https://www.gnu.org/licenses/gpl-3.0.txt');

          if (!await launchUrl(url)) {
            throw Exception('Could not launch $url');
          }
        },
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
        onTap: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: Text('Credits',
                      style: mainTextStyle(TextStyleType.alertTitle)),
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Develop",
                                style: mainTextStyle(
                                    TextStyleType.creditsCateogry)),
                            Text("Daniel Choi",
                                style:
                                    mainTextStyle(TextStyleType.creditsName)),
                            const SizedBox(height: 10),
                            Text("Design",
                                style: mainTextStyle(
                                    TextStyleType.creditsCateogry)),
                            Text("Alkid Shuli, Daniel Choi",
                                style:
                                    mainTextStyle(TextStyleType.creditsName)),
                            const SizedBox(height: 15),
                            Center(
                                child: DialogBottomButton(
                                    text: 'Close',
                                    onTap: () => {
                                          if (Navigator.canPop(context))
                                            {Navigator.pop(context)}
                                        },
                                    style: mainTextStyle(
                                        TextStyleType.creditsClose)))
                          ],
                        ))
                  ],
                );
              });
        },
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
                if (Navigator.canPop(context)) Navigator.pop(context);
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
                    const SizedBox(height: 6),
                    uiInitialScreen(),
                    const SizedBox(height: 3),
                    pinButtons(),
                    const SizedBox(height: 3),
                    albumColumnCount(),
                    const SizedBox(height: 3),
                    showHiddenAlbums(),
                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 12),
                    settingCategory("ABOUT"),
                    const SizedBox(height: 3),
                    versionInfo(),
                    credits(),
                    license(),
                  ])))
    ]));
  }
}
