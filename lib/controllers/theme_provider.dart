import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  final Box box = Hive.box('settingsBox');

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _isDarkMode = box.get('darkMode', defaultValue: false);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    box.put('darkMode', _isDarkMode);
    notifyListeners();
  }
}
