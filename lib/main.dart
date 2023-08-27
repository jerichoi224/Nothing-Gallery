import 'dart:async';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/constants/sharedPrefKey.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/pages/homePage.dart';
import 'package:nothing_gallery/pages/permissionCheckPage.dart';
import 'package:nothing_gallery/util/imageFunctions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

late SharedPref sharedPref;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPref.create();

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      title: 'Spending Manager',
      theme: FlexThemeData.light(
          useMaterial3: true,
          scheme: FlexScheme.hippieBlue,
          fontFamily: GoogleFonts.robotoMono().fontFamily),
      darkTheme: FlexThemeData.dark(
        useMaterial3: true,
        scheme: FlexScheme.hippieBlue,
        darkIsTrueBlack: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainState();

  static _MainState of(BuildContext context) =>
      context.findAncestorStateOfType<_MainState>()!;
}

class _MainState extends State<MainApp> {
  bool permissionChecked = false;
  bool imagesLoaded = false;
  List<AssetEntity> pictures = [];
  List<AlbumInfo> albums = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> getAllImages() async {
    pictures = await loadAllImages();

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    paths.removeWhere((element) => element.id == 'isAll'); // remove recent
    for (AssetPathEntity path in paths) {
      albums.add(await getAlbumInfo(path));
    }

    setState(() {
      imagesLoaded = true;
    });
  }

  Future<void> checkPermission(bool currentState) async {
    final permitted = await Permission.mediaLibrary.request().isGranted &&
        await Permission.photos.request().isGranted;

    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (permitted || ps.isAuth) {
      sharedPref.set(SharedPrefKeys.hasPermission, true);
    } else {
      sharedPref.set(SharedPrefKeys.hasPermission, false);
    }
    setState(() {
      permissionChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 10), () {
      bool currentPermission = sharedPref.get(SharedPrefKeys.hasPermission);

      if (permissionChecked) {
        if (!currentPermission) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => PermissionCheckWidget(
                    parentCtx: context, sharedPref: sharedPref),
              ),
              (Route<dynamic> route) => false);
        }
        if (currentPermission) {
          if (!imagesLoaded) {
            getAllImages();
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HomeWidget(
                      parentCtx: context,
                      sharedPref: sharedPref,
                      pictures: pictures,
                      albums: albums),
                ),
                (Route<dynamic> route) => false);
          }
        }
      } else {
        checkPermission(currentPermission);
      }
    });

    // App Logo screen or sth
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
