import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../models/videos_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/gradient_scaffold.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({super.key, required this.video});

  final Video video;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  initState() {
    log("VideoId: ${widget.video.videoId}");
    super.initState();
    _controller =
        YoutubePlayerController(
          initialVideoId: widget.video.videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            captionLanguage: "en",
          ),
        )..addListener(() {
          if (_controller.value.hasError) {
            if (mounted) {
              CustomSnackbar.show(
                context,
                message: "Error playing video",
                textColor: AppColors.errorColor,
              );
            }
          }
          log("controllerValue: ${_controller.value.isReady}");
          if (_controller.value.isReady) {
            setState(() {
              _isPlayerReady = true;
            });
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("isPlayerReady: $_isPlayerReady");
    log("controllerValue: ${_controller.value.isReady}");
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: Text(
          widget.video.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          progressColors: ProgressBarColors(
            playedColor: AppColors.surface,
            handleColor: AppColors.textFieldColor,
          ),
          onReady: () => _controller.play(),
          onEnded: (metaData) => _controller.pause(),
        ),
      ),
    );
  }
}
