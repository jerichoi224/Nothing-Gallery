// ignore: file_names
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import 'package:nothing_gallery/style.dart';

class VideoPlayerPageWidget extends StatefulWidget {
  final AssetEntity video;

  const VideoPlayerPageWidget({super.key, required this.video});

  @override
  State createState() => _VideoPlayerPageWidgetState();
}

class _VideoPlayerPageWidgetState extends State<VideoPlayerPageWidget> {
  late VideoPlayerController _controller;
  bool decorationVisible = true;
  bool initialized = false;
  late Duration progress;
  Timer? progressBarTimer;

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
    _controller.dispose();
  }

  Future<void> loadVideo() async {
    File? videoFile = await widget.video.file.then((value) {
      if (value == null) {
        Navigator.pop(context);
        return null;
      } else {
        return value;
      }
    });

    if (videoFile == null) return;

    _controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        progress = _controller.value.position;
        int interval = 1000;

        int videoLengthSeconds = _controller.value.duration.inSeconds;
        if (videoLengthSeconds < 60) {
          if (videoLengthSeconds > 40) {
            interval = 100;
          } else {
            interval = 50;
          }
        }

        progressBarTimer =
            Timer.periodic(Duration(milliseconds: interval), (Timer t) {
          if (_controller.value.isPlaying) {
            setState(() {
              progress =
                  Duration(milliseconds: progress.inMilliseconds + interval);
            });
          }
        });

        setState(() {
          initialized = true;
        });
      });
  }

  Widget videoPlayerWrapper(Widget child) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: SafeArea(
            child: GestureDetector(
                onTap: () => setState(() {
                      decorationVisible = !decorationVisible;
                    }),
                child: child)));
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const Center(
        child: SpinKitFadingFour(
          color: Colors.white,
          size: 42.0,
        ),
      );
    }

    return Scaffold(
        body: videoPlayerWrapper(
      _controller.value.isInitialized
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
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                            child: ProgressBar(
                              progress: progress,
                              total: _controller.value.duration,
                              progressBarColor: Colors.red,
                              baseBarColor: Colors.white.withOpacity(0.24),
                              bufferedBarColor: Colors.white.withOpacity(0.24),
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
                          ),
                          SingleItemBottomMenu(
                            asset: widget.video,
                            popOnDelete: true,
                            parentContext: context,
                          )
                        ],
                      )))
            ])
          : Container(),
    ));
  }
}
