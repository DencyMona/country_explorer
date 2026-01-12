import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/country_model.dart';
import '../controllers/bucketlist_provider.dart';

class CountryDetailsScreen extends StatefulWidget {
  final CountryModel country;

  const CountryDetailsScreen({super.key, required this.country});

  @override
  State<CountryDetailsScreen> createState() => _CountryDetailsScreenState();
}

class _CountryDetailsScreenState extends State<CountryDetailsScreen>
    with SingleTickerProviderStateMixin {
  late Box notesBox;
  late TextEditingController noteController;

  late AnimationController _heartController;
  late Animation<double> _heartScale;

  late PageController _pageController;
  int _currentSlide = 0;

  List<Widget> slides = [];

  @override
  void initState() {
    super.initState();

    //Hive notes box
    notesBox = Hive.box('notesBox');
    noteController = TextEditingController(
      text: notesBox.get(widget.country.name, defaultValue: ''),
    );

    // favourite animation
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heartScale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));

    _pageController = PageController();

    _prepareSlides();
  }

  //slide
  void _prepareSlides() async {
    slides = [];

    if (widget.country.coatOfArms.isNotEmpty) {
      final valid = await _isImageUrlValid(widget.country.coatOfArms);
      if (valid) {
        slides.add(
          _glassSlide(title: 'Coat of Arms', image: widget.country.coatOfArms),
        );
      }
    }

    if (widget.country.orthographic.isNotEmpty) {
      final valid = await _isImageUrlValid(widget.country.orthographic);
      if (valid) {
        slides.add(
          _glassSlide(
            title: 'Orthographic',
            image: widget.country.orthographic,
          ),
        );
      }
    }

    setState(() {});
  }

  Future<bool> _isImageUrlValid(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = widget.country;
    final height = MediaQuery.of(context).size.height;
    final bucketProvider = context.watch<BucketListProvider>();
    final isFavorite = bucketProvider.isFavorite(widget.country.name);

    return Scaffold(
      body: Stack(
        children: [
          /// FLAG
          country.flag.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: country.flag,
                  height: height * 0.45,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade300),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/default_flag.jpg',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/default_flag.jpg',
                  height: height * 0.45,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

          /// ICONS
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIcon(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),

                  /// FAVORITE
                  GestureDetector(
                    onTap: () {
                      if (isFavorite) {
                        bucketProvider.remove(widget.country.name);
                      } else {
                        bucketProvider.add({
                          'name': widget.country.name,
                          'region': widget.country.region,
                          'image': widget.country.flag,
                        });
                        _heartController.forward().then(
                          (_) => _heartController.reverse(),
                        );
                      }
                    },
                    child: ScaleTransition(
                      scale: _heartScale,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// COUNTRY NAME
                      Text(
                        country.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// REGION
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 4),
                          Text(country.region),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// POPULATION
                      _infoRow(
                        'Population',
                        NumberFormat('#,###,###').format(country.population),
                      ),

                      /// DETAILS
                      _infoRow('Capital', country.capital),
                      _infoRow(
                        'Timezones',
                        country.timezones.isNotEmpty
                            ? country.timezones.join(', ')
                            : 'N/A',
                      ),
                      _infoRow(
                        'Languages',
                        country.languages.isNotEmpty
                            ? country.languages.join(', ')
                            : 'N/A',
                      ),

                      const SizedBox(height: 24),

                      /// SLIDER
                      if (slides.isNotEmpty) ...[
                        SizedBox(
                          height: 300,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentSlide = index);
                            },
                            children: slides,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// DOT INDICATOR
                        if (slides.length > 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(slides.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 8,
                                width: _currentSlide == index ? 22 : 8,
                                decoration: BoxDecoration(
                                  color: _currentSlide == index
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }),
                          ),

                        const SizedBox(height: 30),
                      ],

                      /// PERSONAL NOTE
                      const Text(
                        'Personal Note',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: noteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your travel thoughts...',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          notesBox.put(country.name, value);
                        },
                      ),

                      if (noteController.text.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              notesBox.delete(country.name);
                              noteController.clear();
                              setState(() {});
                            },
                            child: const Text(
                              'Delete Note',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// GLASS SLIDE
  Widget _glassSlide({required String title, required String image}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),

        const SizedBox(height: 8),

        /// IMAGE
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: image,
              width: double.infinity,
              height: 150,
              fit: BoxFit.contain,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),
          ),
        ),
      ],
    );
  }

  /// ICON
  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// INFO ROW
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
