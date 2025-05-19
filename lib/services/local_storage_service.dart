import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _profileImageKey = 'profile_image';

  // Save profile image as base64 string
  static Future<void> saveProfileImage(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, base64Image);
  }

  // Get profile image as base64 string
  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  // Clear profile image
  static Future<void> clearProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileImageKey);
  }
}