import 'dart:convert';
import 'dart:developer';

import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_routes.dart';

class AuthServices {
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Register Route
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(registerRoute),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "fullName": fullName,
          "email": email,
          "password": password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData;
      } else {
        final errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Registration failed';
        throw Exception(errorMessage);
      }
    } catch (err) {
      throw err.toString();
    }
  }

  //Login Route
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginRoute),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );
      log("response: ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        // Handle different error response formats
        final errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Invalid email or password';
        throw Exception(errorMessage);
      }
    } catch (err) {
      throw err.toString();
    }
  }

  // Verify parental PIN
  Future<bool> verifyPin(String pin) async {
    final userId = getUserId();
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse("$verifyPinRoute/$userId"),
      headers: headers,
      body: jsonEncode({"pin": pin}),
    );
    return response.statusCode == 200;
  }
}
