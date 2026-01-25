import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _firstName;
  String? _lastName;
  String? _profileImagePath;
  String? _mobileNumber;
  String? _email;
  bool _isLoggedIn = false;

  String get fullName => '$_firstName $_lastName';
  String get firstName => _firstName ?? '';
  String get lastName => _lastName ?? '';
  String? get profileImagePath => _profileImagePath;
  String? get mobileNumber => _mobileNumber;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _firstName = prefs.getString('firstName');
      _lastName = prefs.getString('lastName');
      _mobileNumber = prefs.getString('mobileNumber');
      _email = prefs.getString('email');
      _profileImagePath = prefs.getString(
        'profileImagePath',
      ); // might be null or emoji
    }
    notifyListeners();
  }

  Future<void> setUserDetails({
    required String firstName,
    required String lastName,
    String? profileImagePath,
    required String mobileNumber,
    String? email,
  }) async {
    _firstName = firstName;
    _lastName = lastName;
    _profileImagePath = profileImagePath;
    _mobileNumber = mobileNumber;
    _email = email;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('mobileNumber', mobileNumber);
    if (email != null) await prefs.setString('email', email);
    if (profileImagePath != null)
      await prefs.setString('profileImagePath', profileImagePath);

    notifyListeners();
  }

  Future<void> logout() async {
    _firstName = null;
    _lastName = null;
    _profileImagePath = null;
    _mobileNumber = null;
    _email = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
