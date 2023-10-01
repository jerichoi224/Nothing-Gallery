// ignore: file_names
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import 'package:nothing_gallery/style.dart';

// ignore: must_be_immutable
class VideoPlayerPageWidget extends StatefulWidget {
  late AssetEntity video;

  VideoPlayerPageWidget({super.key, required this.video});

  @override
  State createState() => _VideoPlayerPageWidgetState();
}

class _VideoPlayerPageWidgetState extends State<VideoPlayerPageWidget> {
  late VideoPlayerController _controller;
  bool decorationVisible = true;
  bool initialized = false;
  late Duration progress;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    loadVideo();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  Future<void> loadVideo() async {
    File? videoFile = await widget.video.file;
    if (videoFile != null) {
      _controller = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          progress = _controller.value.position;

          if (_controller.value.duration.inSeconds > 60) {
            timer = Timer.periodic(
                const Duration(seconds: 1),
                (Timer t) => {
                      if (_controller.value.isPlaying)
                        {
                          setState(
                            () {
                              progress =
                                  Duration(seconds: progress.inSeconds + 1);
                            },
                          )
                        }
                    });
          } else {
            timer = Timer.periodic(
                const Duration(milliseconds: 50),
                (Timer t) => {
                      if (_controller.value.isPlaying)
                        {
                          //This error might indicate a memory leak if setState() is being called because another object is retaining a reference to this State object after it has been removed from the tree. To avoid memory leaks, consider breaking the reference to this object during dispose().
                          setState(
                            () {
                              progress = Duration(
                                  milliseconds: progress.inMilliseconds + 50);
                            },
                          )
                        }
                    });
          }

          setState(() {
            initialized = true;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) return Container();

    return Scaffold(
      body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return true;
          },
          child: SafeArea(
              child: GestureDetector(
            onTap: () => setState(() {
              decorationVisible = !decorationVisible;
            }),
            child: _controller.value.isInitialized
                ? Stack(children: <Widget>[
                    Center(
                        child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )),
                    AnimatedOpacity(
                        opacity: decorationVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            color: const Color.fromARGB(150, 0, 0, 0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.arrow_back)),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.info)),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onPressed: () {
                                          setState(() {
                                            _controller.value.isPlaying
                                                ? _controller.pause()
                                                : _controller.play();
                                          });
                                        },
                                        icon: Icon(
                                          _controller.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_circle_filled_sharp,
                                          size: 48,
                                        )),
                                  ],
                                ),
                                const Spacer(),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 35),
                                  child: ProgressBar(
                                    progress: progress,
                                    total: _controller.value.duration,
                                    progressBarColor: Colors.red,
                                    baseBarColor:
                                        Colors.white.withOpacity(0.24),
                                    bufferedBarColor:
                                        Colors.white.withOpacity(0.24),
                                    thumbColor: Colors.white,
                                    barHeight: 3.0,
                                    thumbRadius: 5.0,
                                    timeLabelLocation: TimeLabelLocation.sides,
                                    timeLabelTextStyle: mainTextStyle(
                                        TextStyleType.videoPlayerDuration),
                                    onSeek: (position) {
                                      _controller.seekTo(position);
                                      setState(() {
                                        progress = position;
                                      });
                                    },
                                  ),
                                )
                              ],
                            )))
                  ])
                : Container(),
          ))),
    );
  }
}
