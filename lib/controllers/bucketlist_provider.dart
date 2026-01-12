import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class BucketListProvider extends ChangeNotifier {
  final Box bucketBox = Hive.box('bucketBox');

  List<Map<String, dynamic>> _bucketList = [];

  BucketListProvider() {
    loadBucket();
  }

  //save country from Hive
  void loadBucket() {
    final List<Map<String, dynamic>> list = [];
    for (var key in bucketBox.keys) {
      final value = bucketBox.get(key);
      list.add(Map<String, dynamic>.from(value));
    }
    _bucketList = list;
    notifyListeners();
  }

  List<Map<String, dynamic>> get bucketList => _bucketList;

  //Add country
  void add(Map<String, dynamic> country) {
    bucketBox.put(country['name'], country);
    loadBucket();
  }

  //Remove country
  void remove(String name) {
    bucketBox.delete(name);
    loadBucket();
  }

  // Check favorite
  bool isFavorite(String name) {
    return bucketBox.containsKey(name);
  }

  // Sort Alphabetically
  void sortAlphabetical() {
    _bucketList.sort(
      (a, b) =>
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()),
    );
    notifyListeners();
  }

  // Sort By Region
  void sortByRegion() {
    _bucketList.sort(
      (a, b) => (a['region'] ?? '').toString().compareTo(
        (b['region'] ?? '').toString(),
      ),
    );
    notifyListeners();
  }
}
