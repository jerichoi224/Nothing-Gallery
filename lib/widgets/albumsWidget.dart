import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';

class AlbumsWidget extends StatefulWidget {
  AlbumsWidget({Key? key}) : super(key: key);

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends State<AlbumsWidget> {
  @override
  void initState() {
    super.initState();
  }

  void getImages() {}

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
                'ALBUMS',
                style: PageTitleTextStyle(),
              )))
        ])));
  }
}
