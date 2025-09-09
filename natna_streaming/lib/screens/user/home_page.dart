import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/video_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blocked_content_card.dart';
import '../../widgets/content_card.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/search_results.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool isChannel = false;

  List<String> tabItems = ["All", "Music", "Videos", "Channels", "Blocked"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    ref.read(videoProvider.notifier).tabController = _tabController;
    _searchController.addListener(_onSearchTextChange);

    // Fetch blocked items initially
    ref.read(videoProvider.notifier).fetchBlockedItems();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      ref.read(videoProvider.notifier).filterSearchResults();
      if (_tabController.index == 4) {
        ref.read(videoProvider.notifier).fetchBlockedItems();
      }
    }
  }

  void _onSearchTextChange() {
    final query = _searchController.text;
    final notifier = ref.read(videoProvider.notifier);
    if (query.isEmpty) {
      notifier.clearSearch();
    } else {
      notifier.onSearchChanged(query, isChannel);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChange);
    _searchController.dispose();
    _tabController.dispose();
    // if (mounted) {
    //   ref.read(videoProvider.notifier).cleanup();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final videoAsync = ref.watch(videoProvider);
    final videoProviderNotifier = ref.watch(videoProvider.notifier);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Curated Videos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Container(
            width: size.width,
            padding: const EdgeInsets.all(4),
            color: AppColors.background,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              height: 130,
              child: Column(
                children: [
                  SizedBox(
                    height: 83,
                    child: Column(
                      children: [
                        SizedBox(
                          width: size.width,
                          height: 35,
                          child: TextFormField(
                            style: TextStyle(fontSize: 12),
                            controller: _searchController,
                            onChanged: (query) {
                              videoProviderNotifier.onSearchChanged(
                                query,
                                isChannel,
                              );
                            },
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                // onTap: _setupSearch,
                                onTap: () =>
                                    videoProviderNotifier.onSearchChanged(
                                      _searchController.text,
                                      isChannel,
                                    ),
                                child: const Icon(
                                  Icons.search,
                                  color: AppColors.borderColor,
                                ),
                              ),
                              hint: Text(
                                "Search Videos...",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.textFieldColor.withOpacity(
                                0.2,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 8,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.borderColor.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.borderColor.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.borderColor.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isChannel,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        isChannel = value;
                                      });
                                      //Trigger search with new type
                                      videoProviderNotifier.onSearchChanged(
                                        _searchController.text,
                                        isChannel,
                                      );
                                    }
                                  },
                                ),
                                Text("Channel"),
                              ],
                            ),
                            SizedBox(
                              height: 32,
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textFieldColor,
                                  shape: BeveledRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  videoProviderNotifier.clearSearch();
                                },
                                child: Text(
                                  "Clear",
                                  style: TextStyle(color: AppColors.onSurface),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    tabAlignment: TabAlignment.center,
                    indicator: const BoxDecoration(),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 3),
                    dividerColor: Colors.transparent,
                    tabs: List.generate(tabItems.length, (index) {
                      final isSelected = _tabController.index == index;
                      return Container(
                        height: 32,
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.onSurface
                              : AppColors.textFieldColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tabItems[index],
                          style: TextStyle(
                            // fontSize: 12,
                            color: isSelected
                                ? AppColors.background
                                : Colors.white,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: videoProviderNotifier.searchResults.isNotEmpty
          ? SearchResults(result: videoProviderNotifier.searchResults)
          : videoAsync.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return const Center(child: Text("No videos available"));
                }
                return _tabController?.index != 4
                    ? ContentCard(contents: videos)
                    : BlockedContentCard(contents: videos);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }
}
