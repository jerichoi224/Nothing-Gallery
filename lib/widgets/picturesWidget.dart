import 'package:flutter/material.dart';

class PicturesWidget extends StatefulWidget {
  PicturesWidget({Key? key}) : super(key: key);

  @override
  State createState() => _PicturesState();
}

class _PicturesState extends State<PicturesWidget> {
  @override
  void initState() {
    super.initState();
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

        ])));
  }
}
