import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../models/videos_model.dart';
import '../services/content_services.dart';
import '../utils/auth_utils.dart';

final apiServiceProvider = Provider<ContentServices>(
  (ref) => ContentServices(),
);

final videoProvider = AsyncNotifierProvider<VideoNotifier, List<Video>>(
  () => VideoNotifier(),
);

class VideoNotifier extends AsyncNotifier<List<Video>> {
  late final BehaviorSubject<Map<String, dynamic>> searchSubject;
  TabController? tabController;
  List<Video> searchResults = [];
  List<Video> filteredVideos = [];
  List<Video> blockedItems = [];
  List<Video> curatedVideos = [];
  bool _hasFetchedBlockedItems = false;

  @override
  Future<List<Video>> build() async {
    final userId = AuthUtils.getUserId();
    final token = AuthUtils.getToken();
    if (userId == null && token == null) throw Exception("User not logged in");
    initializeSearch();
    curatedVideos = await _fetchCuratedVideos();
    return curatedVideos;
  }

  Future<List<Video>> _fetchCuratedVideos() async {
    return ref.read(apiServiceProvider).getCuratedVideos();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    curatedVideos = await _fetchCuratedVideos();
    if (!_hasFetchedBlockedItems) {
      await fetchBlockedItems();
    }
  }

  Future<void> blockItem(String itemId, bool isChannel) async {
    await ref.read(apiServiceProvider).blockItem(itemId, isChannel);
    await refresh();
  }

  Future<void> fetchBlockedItems() async {
    if (tabController?.index == 4) {
      state = const AsyncLoading();
    }
    final result = await ref.read(apiServiceProvider).getBlockedItems();
    blockedItems = result
        .map(
          (content) => Video(
            description: content["description"] ?? "",
            thumbnail: content["thumbnail"] ?? "",
            title: content["title"] ?? "",
            videoId: content["id"],
            channelId: content["channelId"] ?? content["id"],
          ),
        )
        .toList();
    _hasFetchedBlockedItems = true;
    if (tabController?.index == 4) {
      state = AsyncData(blockedItems);
    }
  }

  Future<void> addToWhitelist(String itemId) async {
    await ref.read(apiServiceProvider).addToWhitelist(itemId);
    await refresh();
  }

  Future<void> unblockItem(String itemId) async {
    await ref.read(apiServiceProvider).unblockItem(itemId);
    await refresh();
  }

  //Report video
  Future<void> reportItem(String itemId, bool isChannel) async {
    await ref.read(apiServiceProvider).reportItem(itemId, isChannel);
  }

  Future<List<dynamic>> searchContent(
    String query, {
    required String type,
  }) async {
    return ref.read(apiServiceProvider).searchContent(query, type: type);
  }

  void initializeSearch() {
    searchSubject = BehaviorSubject<Map<String, dynamic>>();
    searchSubject.stream
        .debounceTime(const Duration(milliseconds: 300))
        .listen(
          (data) async {
            final query = data["query"] as String;
            final isChannel = data["isChannel"] as bool;
            final type = isChannel ? 'channel' : "video";
            if (query.isNotEmpty) {
              try {
                final results = await ref
                    .read(apiServiceProvider)
                    .searchContent(query, type: type);
                searchResults = results
                    .map(
                      (content) => Video(
                        description: content["description"],
                        thumbnail: content["thumbnail"],
                        title: content["title"],
                        videoId: content["id"],
                        channelId: content["channelId"] ?? content["id"],
                      ),
                    )
                    .toList();
                filterSearchResults();
                state = AsyncData(
                  searchResults.isNotEmpty
                      ? searchResults
                      : await _fetchCuratedVideos(),
                );
              } catch (err) {
                state = AsyncError(err, StackTrace.current);
              }
            } else {
              searchResults = [];
              filterSearchResults();
            }
          },
          onError: (error, stackTrace) {
            state = AsyncError(
              error ?? "Unknown error",
              stackTrace ?? StackTrace.current,
            );
          },
          cancelOnError: true,
        );
  }

  void filterSearchResults() {
    if (tabController == null) return;
    if (tabController!.index == 4) {
      state = AsyncData(blockedItems);
      return;
    }
    filteredVideos = searchResults.where((video) {
      final titleLower = video.title.toLowerCase();
      final matchesTab =
          tabController!.index == 0 || // All
          (tabController!.index == 1 &&
              titleLower.contains("music")) || // Music
          (tabController!.index == 2 &&
              !video.videoId.startsWith("UC")) || // Videos
          (tabController!.index == 3 &&
              video.videoId.startsWith("UC")); // Channels
      return matchesTab;
    }).toList();

    if (filteredVideos.isNotEmpty) {
      state = AsyncData(filteredVideos);
    } else if (searchResults.isNotEmpty) {
      state = AsyncData(searchResults);
    } else {
      state = AsyncData(curatedVideos);
    }
  }

  void onSearchChanged(String query, bool isChannel) {
    searchSubject.add({"query": query, "isChannel": isChannel});
  }

  void cleanup() {
    tabController?.removeListener(filterSearchResults);
    searchSubject.close();
  }

  void clearSearch() async {
    searchResults = [];
    filteredVideos = [];
    state = const AsyncLoading();
    state = AsyncData(await _fetchCuratedVideos());
  }
}
