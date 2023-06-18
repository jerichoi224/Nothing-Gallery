import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("Albums"));
  }
}
