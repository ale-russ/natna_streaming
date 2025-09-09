import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

final baseUrl = Platform.isAndroid
    ? "http://192.168.1.18:3000"
    : "http://localhost:3000";

Future<String?> _gotToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

Future<Map<String, String>> getHeaders() async {
  final token = await _gotToken();
  return {
    "Content-Type": "application/json",
    if (token != null) "Authorization": 'Bearer $token',
  };
}

final registerRoute = "$baseUrl/auth/signup";
final loginRoute = "$baseUrl/auth/login";
final verifyPinRoute = "$baseUrl/auth/verify-pin";

final curatedVideosRoutes = "$baseUrl/api/youtube/curated";
final blockVideosRoutes = "$baseUrl/api/youtube/block";
final searchVideosRoutes = "$baseUrl/api/youtube/search";
final addToWhitelistRoute = "$baseUrl/api/youtube/addToWhitelist";
final reportChannelRoute = "$baseUrl/api/youtube/reportChannel";
final unblockRoute = "$baseUrl/api/youtube/unblock";
final fetchBlockedRoute = "$baseUrl/api/youtube/blacklist";
