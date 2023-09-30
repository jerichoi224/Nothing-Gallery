import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/pages/pages.dart';

late SharedPref sharedPref;
late StreamController<Event> eventController;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPref.create();
  eventController = StreamController<Event>.broadcast();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nothing Gallery',
      theme: FlexThemeData.dark(
        useMaterial3: true,
        scheme: FlexScheme.hippieBlue,
        darkIsTrueBlack: true,
      ),
      // TODO: add light/dark Theme:
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainState();
}

class _MainState extends State<MainApp> {
  bool permissionGranted = false;
  bool permissionChecked = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  void initialize() {
    setState(() {
      initialized = true;
    });
  }

  Future<void> checkPermission() async {
    bool permitted = false;
    var androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt <= 32) {
      permitted = await Permission.storage.request().isGranted;
    } else {
      permitted = await Permission.mediaLibrary.request().isGranted &&
          await Permission.photos.request().isGranted &&
          await Permission.videos.request().isGranted;
    }
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (permitted || ps.isAuth) {
      initialize();
      setState(() {
        permissionChecked = permissionGranted = true;
      });
    } else {
      setState(() {
        permissionChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (permissionChecked) {
      if (!permissionGranted) {
        // No Permission
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => PermissionCheckWidget(),
              ),
              (Route<dynamic> route) => false);
        });
      } else if (initialized) {
        // Permission & loaded
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeWidget(),
              ),
              (Route<dynamic> route) => false);
        });
      }
    }

    // TODO: App Logo screen or loading screen
    return Scaffold(
        body: SafeArea(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                    child: SizedBox(
                        height: 150,
                        width: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(300.0),
                          child:
                              const Image(image: AssetImage('assets/icon.png')),
                        ))))
          ]),
    ));
  }
}
