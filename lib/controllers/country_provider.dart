import 'package:flutter/material.dart';
import '../api/country_api_service.dart';
import '../models/country_model.dart';

class CountryProvider extends ChangeNotifier {
  final CountryApiService _api = CountryApiService();

  List<CountryModel> _countries = [];
  List<CountryModel> filteredCountries = [];

  String selectedRegion = 'All';
  List<String> regions = ['All'];

  bool loading = false;
  String error = '';
  bool isAscending = true;

  Future<void> loadCountries() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      _countries = await _api.fetchCountries();
      filteredCountries = _countries;

      final uniqueRegions = _countries
          .map((c) => c.region)
          .where((r) => r.isNotEmpty)
          .toSet()
          .toList();

      regions = ['All', ...uniqueRegions];
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _applySorting() {
    filteredCountries.sort((a, b) {
      return isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
    });
  }

  void search(String query) {
    filteredCountries = _countries
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    _applySorting();
    notifyListeners();
  }

  void toggleSortOrder() {
    isAscending = !isAscending;

    filteredCountries.sort((a, b) {
      return isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
    });

    notifyListeners();
  }

  void filterByRegion(String region) {
    selectedRegion = region;

    if (region == 'All') {
      filteredCountries = _countries;
    } else {
      filteredCountries = _countries.where((c) => c.region == region).toList();
    }

    _applySorting();
    notifyListeners();
  }
}
