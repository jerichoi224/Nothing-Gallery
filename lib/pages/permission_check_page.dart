import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

//TODO:
class PermissionCheckPage extends StatefulWidget {
  const PermissionCheckPage({super.key});

  @override
  State createState() => _PermissionCheckState();
}

class _PermissionCheckState
    extends LifecycleListenerState<PermissionCheckPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> openSetting() async {
    await PhotoManager.openSetting();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: SafeArea(
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              Text(
                'App Needs Permission',
                style: mainTextStyle(TextStyleType.settingsPageTitle),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 25),
                  child: Text(
                    '1. Open Settings\n2. Open Permissions\n3. Tap Photos and videos\n4. Tap Allow',
                    style: mainTextStyle(TextStyleType.settingsPageDescription),
                  )),
              SizedBox(
                  height: 60,
                  width: 240,
                  child: WideIconButton(
                      text: "Open Settings",
                      iconData: Icons.settings,
                      onTapHandler: () {
                        openSetting();
                      }))
            ])))));
  }

  Future<void> checkPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return const MainApp();
          },
        ), (Route<dynamic> route) => false);
      });
    } else {
      return;
    }
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    checkPermission();
  }
}
