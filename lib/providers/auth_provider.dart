import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String _userPrefsKey = 'auth_user_credentials';
  static const String _sessionPrefsKey = 'auth_active_session';

  String? _currentUser;
  bool _isLoading = false;

  String? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _checkActiveSession();
  }

  /// Checks if a valid login token session already exists on disk.
  Future<void> _checkActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString(_sessionPrefsKey);
    notifyListeners();
  }

  /// Registers a new user locally on the device disk.
  Future<bool> signUp(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Pull down existing user register registry
      final String? existingUsersRaw = prefs.getString(_userPrefsKey);
      Map<String, dynamic> userRegistry = existingUsersRaw != null 
          ? json.decode(existingUsersRaw) as Map<String, dynamic>
          : {};

      if (userRegistry.containsKey(username)) {
        // User variant identity already allocated
        return false;
      }

      // Append credentials into localized map registry (In production, hash this string)
      userRegistry[username] = password;
      await prefs.setString(_userPrefsKey, json.encode(userRegistry));
      
      // Auto-authenticate upon successful pipeline generation
      _currentUser = username;
      await prefs.setString(_sessionPrefsKey, username);
      return true;
    } catch (e) {
      debugPrint('Registration Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validates inbound security credentials against device records.
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existingUsersRaw = prefs.getString(_userPrefsKey);
      
      if (existingUsersRaw == null) return false;

      final Map<String, dynamic> userRegistry = json.decode(existingUsersRaw) as Map<String, dynamic>;

      if (userRegistry.containsKey(username) && userRegistry[username] == password) {
        _currentUser = username;
        await prefs.setString(_sessionPrefsKey, username);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Authentication Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the runtime and persistent user credentials session cache.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPrefsKey);
    _currentUser = null;
    notifyListeners();
  }
}