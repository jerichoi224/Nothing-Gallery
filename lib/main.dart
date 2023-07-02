import 'dart:async';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nothing_gallery/constants/sharedPrefKey.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/pages/homeWidget.dart';
import 'package:nothing_gallery/pages/permissionCheckWidget.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'Spending Manager',
        theme: FlexThemeData.light(
            useMaterial3: true,
            scheme: FlexScheme.hippieBlue,
            fontFamily: GoogleFonts
                .robotoMono()
                .fontFamily),
        darkTheme: FlexThemeData.dark(
          useMaterial3: true,
          scheme: FlexScheme.hippieBlue,
          darkIsTrueBlack: true,
        ),
        themeMode: ThemeMode.dark,
        home: const MainApp(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) =>
              HomeWidget(parentCtx: context, sharedPref: sharedPref),
          '/permission': (BuildContext context) =>
              PermissionCheckWidget(parentCtx: context, sharedPref: sharedPref),
        });
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkPermission(bool currentState) async {
    final ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
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
        if (currentPermission) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/permission', (Route<dynamic> route) => false);
        }
      } else {
        checkPermission(currentPermission);
      }
    });

    // App Logo screen or sth
    return Scaffold(
        body: Column(children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .viewPadding
                .top,
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                  child: Text(
                    'Loading Screen (Icon)',
                    style: pageTitleTextStyle(),
                  )))
        ]));
  }
}
