import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country_model.dart';

class CountryApiService {
  static const String baseUrl =
      'https://api.sampleapis.com/countries/countries';

  Future<List<CountryModel>> fetchCountries() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CountryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }
}
