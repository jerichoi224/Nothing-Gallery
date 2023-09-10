// ignore: file_names
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class VideoPlayerPageWidget extends StatefulWidget {
  late AssetEntity video;
  late StreamController eventController;

  VideoPlayerPageWidget(
      {super.key, required this.video, required this.eventController});

  @override
  State createState() => _VideoPlayerPageWidgetState();
}

class _VideoPlayerPageWidgetState extends State<VideoPlayerPageWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  Future<void> loadVideo() async {
    File? videoFile = await widget.video.file;
    if (videoFile != null) {
      _controller = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return true;
          },
          child: SafeArea(
              child: GestureDetector(
                  child: Stack(children: <Widget>[
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
          ])))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
