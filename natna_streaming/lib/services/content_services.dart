import 'dart:convert';
import 'dart:developer';

import "package:http/http.dart" as http;

import '../models/videos_model.dart';
import 'api_routes.dart';
import 'auth_services.dart';

class ContentServices {
  // Fetch curated video
  Future<List<Video>> getCuratedVideos() async {
    final userId = await AuthServices().getUserId();
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$curatedVideosRoutes/$userId"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["videos"] as List)
          .map((item) => Video.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch curated videos: ${response.body}');
    }
  }

  // Block a video or channel
  Future<void> blockItem(String itemId, bool isChannel) async {
    final userId = await AuthServices().getUserId();
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse("$blockVideosRoutes/$userId"),
      headers: headers,
      body: jsonEncode({'itemId': itemId, "isChannel": isChannel}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to block item: ${response.body}');
    }
  }

  // Search for channel or videos
  Future<List<dynamic>> searchContent(
    String query, {
    String type = "channel",
  }) async {
    final userId = await AuthServices().getUserId();
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$searchVideosRoutes/$userId?query=$query&type=$type"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"] as List;
    } else {
      throw Exception("Failed to search: ${response.body}");
    }
  }

  // Add to whitelist
  Future<void> addToWhitelist(String itemId) async {
    final userId = await AuthServices().getUserId();
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$addToWhitelistRoute/$userId'),
      headers: headers,
      body: jsonEncode({'itemId': itemId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add to whitelist: ${response.body}');
    }
  }

  //Remove from blacklist;
  Future<void> unblockItem(String itemId) async {
    final userId = await AuthServices().getUserId();
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse("$unblockRoutes/$userId"),
      headers: headers,
      body: jsonEncode({"itemId": itemId}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to remove from blacklist: ${response.body}");
    }
  }

  // Fetch blocked items
  Future<List<dynamic>> fetchBlockedItems() async {
    final userId = await AuthServices().getUserId();
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$fetchBlockedRoutes/$userId"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch blocked items: ${response.body}");
    }
    final data = jsonDecode(response.body);
    return data["results"] as List<dynamic>;
  }

  // Report item
  Future<void> reportItem(String itemId, bool isChannel) async {
    final userId = await AuthServices().getUserId();
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse("$reportChannelRoute/$userId"),
      headers: headers,
      body: jsonEncode({"itemId": itemId, "isChannel": isChannel}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to report item:${response.body}");
    }
  }
}
