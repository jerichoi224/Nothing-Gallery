import 'package:flutter/material.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionCheckWidget extends StatefulWidget {
  final BuildContext parentCtx;
  late SharedPref sharedPref;

  PermissionCheckWidget(
      {super.key, required this.parentCtx, required this.sharedPref});

  @override
  State createState() => _PermissionCheckState();
}

class _PermissionCheckState extends State<PermissionCheckWidget> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> openSetting() async {
    await PhotoManager.openSetting(); // 권한 설정 페이지 이동
    PermissionState permission = await PhotoManager.requestPermissionExtend();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                  child: Text(
                'Permission Check Screen',
                style: pageTitleTextStyle(),
              )))
        ])));
  }
}