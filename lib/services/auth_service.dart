import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:pet_store_mobile_app/config/env_config.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class AuthService {
  static final String baseUrl = EnvConfig.apiBaseUrl;
  static final String apiV = EnvConfig.apiVersion;
  static const String sessionCookieKey = 'PHPSESSID';

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiV/users.php/register'),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'An error occurred during registration',
      };
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiV/users.php/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // for non-web platforms, manually handle the cookie
        if (!kIsWeb) {
          String? cookie = response.headers['set-cookie'];
          if (cookie != null) {
            final sessionId = cookie.split(';')[0];
            await saveSessionCookie(sessionId);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> getSessionCookie() async {
    // for web, we don't need to manually handle cookies so return null
    if (kIsWeb) return null;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(sessionCookieKey);
  }

  Future<void> saveSessionCookie(String cookie) async {
    // only save cookie manually for non-web platforms
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionCookieKey, cookie);
  }

  Future<void> clearSessionCookie() async {
    // only clear cookie manually for non-web platforms
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionCookieKey);
  }

  Future<bool> logout() async {
    try {
      print('Starting logout process...'); // Debug print

      final cookie = await getSessionCookie();
      print('Retrieved cookie: $cookie'); // Debug print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (!kIsWeb && cookie != null) {
        headers['Cookie'] = cookie;
      }

      print(
          'Sending logout request to: $baseUrl/$apiV/users.php/logout'); // Debug print
      final response = await http.post(
        Uri.parse(
            '$baseUrl/$apiV/users.php/logout'), // Updated path to match login
        headers: headers,
      );

      print('Logout response status: ${response.statusCode}'); // Debug print
      print('Logout response body: ${response.body}'); // Debug print

      // Clear cookie regardless of response
      await clearSessionCookie();

      return response.statusCode == 200;
    } catch (e) {
      print('Logout error: $e');
      // Still clear cookie even if request fails
      await clearSessionCookie();
      throw Exception('Logout failed: $e');
    }
  }
}
