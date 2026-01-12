import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../screens/country_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountryCard extends StatelessWidget {
  final CountryModel country;
  const CountryCard({super.key, required this.country});

  bool _isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 30,
        child: country.flag.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: country.flag,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  'assets/images/default_flag.jpg',
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/default_flag.jpg',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset('assets/images/default_flag.jpg', fit: BoxFit.cover),
      ),
      title: Text(country.name),
      subtitle: Text(country.capital.isNotEmpty ? country.capital : 'N/A'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CountryDetailsScreen(country: country),
          ),
        );
      },
    );
  }
}
