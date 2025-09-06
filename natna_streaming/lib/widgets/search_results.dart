import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/videos_model.dart';
import '../notifiers/video_notifier.dart';
import '../theme/app_colors.dart';

class SearchResults extends ConsumerWidget {
  const SearchResults({super.key, required this.result});

  final List<Video> result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: result.length,
        itemBuilder: (context, index) {
          final video = result[index];
          final bool isChannelItem = video.videoId.startsWith('UC');
          final String itemId = video.videoId;
          final channelId = video.channelId ?? video.videoId;
          return InkWell(
            onTap: isChannelItem
                ? null
                : () => context.push("/video-player", extra: video),
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(6),
                  side: BorderSide(
                    color: AppColors.borderColor.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      width: size.width,
                      video.thumbnail,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: size.width * 0.6,
                      margin: const EdgeInsets.only(left: 8),
                      child: Text(
                        video.title,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: size.width * 0.3,
                            child: Text(
                              "This is the video description This is the video description",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            color: AppColors.background,
                            onSelected: (value) {
                              final notifier = ref.read(videoProvider.notifier);
                              if (value == "no_video") {
                                notifier.blockItem(itemId, false);
                              } else if (value == "no_channel") {
                                notifier.blockItem(channelId, false);
                              } else if (value == "report_channel") {
                                notifier.reportItem(channelId, true);
                              }
                            },
                            itemBuilder: (context) => [
                              if (!isChannelItem)
                                const PopupMenuItem<String>(
                                  value: "no_video",
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.block,
                                        color: AppColors.borderColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text("Don't recommend video"),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem<String>(
                                value: "no_channel",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.remove_circle,
                                      color: AppColors.borderColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Don't recommend channel"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: "report_channel",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.report,
                                      color: AppColors.borderColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Report channel"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
