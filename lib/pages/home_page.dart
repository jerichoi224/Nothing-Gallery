import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:nothing_gallery/pages/pages.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/util/util.dart';

@immutable
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeWidget> with SingleTickerProviderStateMixin {
  static final List<Tab> _tabs =
      HomeTabMenu.values.map((tab) => Tab(text: tab.text)).toList();

  static const double navBarHeight = 50;
  List<Widget> tabPages() => [const PicturesWidget(), const AlbumsWidget()];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _tabController = TabController(
        initialIndex: Provider.of<AppStatus>(context, listen: false).activeTab,
        length: _tabs.length,
        vsync: this);
    _tabController.addListener(_tabListener);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _tabListener() {
    final imageSelection = Provider.of<ImageSelection>(context, listen: false);
    final appStatus = Provider.of<AppStatus>(context, listen: false);
    if (_tabController.index == 1 && imageSelection.selectionMode) {
      imageSelection.endSelection();
    }

    if (appStatus.activeTab != _tabController.index) {
      appStatus.setActiveTab(_tabController.index);
    }
  }

  Widget homePopupMenu() {
    return PopupMenuButton<HomePopupMenu>(
        tooltip: '',
        offset: const Offset(0, -63),
        color: Colors.black,
        onSelected: onHomePopupMenuSelected,
        child: const InkWell(
          child: Icon(
            Icons.list,
            size: 26,
          ),
        ),
        itemBuilder: (BuildContext context) {
          return [
            for (final value in HomePopupMenu.values)
              PopupMenuItem(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      value.text,
                      textAlign: TextAlign.center,
                      style: mainTextStyle(TextStyleType.popUpMenu),
                    ),
                  ))
          ];
        });
  }

  void onHomePopupMenuSelected(HomePopupMenu item) {
    switch (item) {
      case HomePopupMenu.settings:
        openSettings(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    var bottomHeight = MediaQuery.of(context).viewPadding.bottom;

    return MediaQuery(
        data: mediaQueryData.copyWith(textScaleFactor: 1.0),
        child: DefaultTabController(
          initialIndex: 1,
          length: 2,
          child: Scaffold(
            bottomNavigationBar: SizedBox(
                height: navBarHeight + bottomHeight,
                child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Consumer<ImageSelection>(
                            builder: (context, imageSelection, child) {
                          return TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.transparent,
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.white12;
                                }
                                return Colors.transparent;
                              },
                            ),
                            labelStyle: mainTextStyle(TextStyleType.navBar),
                            unselectedLabelStyle:
                                mainTextStyle(TextStyleType.navBar),
                            tabs: _tabs,
                            labelColor: Colors.red,
                          );
                        }),
                      ),
                      Expanded(
                          flex: 1,
                          child: SizedBox(
                              height: navBarHeight, child: homePopupMenu())),
                    ],
                  ),
                  SizedBox(height: bottomHeight)
                ])),
            body: TabBarView(controller: _tabController, children: tabPages()),
          ),
        ));
  }
}
