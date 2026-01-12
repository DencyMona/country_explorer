import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/country_provider.dart';
import '../widgets/country_card.dart';
import '../widgets/loading_shimmer.dart';
import 'bucket_list_screen.dart';
import '../widgets/error_retry_widget.dart';
import '../controllers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const Color primaryColor = Color(0xFF8E7CC3);

final List<Color> headerGradient = [
  primaryColor.withOpacity(0.85),
  primaryColor.withOpacity(0.55),
  Colors.white,
];

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CountryProvider>().loadCountries();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Countries',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: headerGradient,
            ),
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (_, theme, __) => IconButton(
              icon: Icon(theme.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: theme.toggleTheme,
            ),
          ),
          IconButton(
            icon: Icon(
              provider.isAscending
                  ? Icons.sort_by_alpha
                  : Icons.sort_by_alpha_outlined,
            ),
            onPressed: provider.toggleSortOrder,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BucketListScreen()),
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: provider.loadCountries,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  /// Search
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search country',
                        prefixIcon: const Icon(Icons.search),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: provider.search,
                    ),
                  ),

                  const SizedBox(width: 8),

                  ///Filter icon
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      _showRegionFilter(context);
                    },
                  ),
                ],
              ),
            ),

            /// Country list
            Expanded(
              child: provider.loading
                  ? const CountryListShimmer()
                  : provider.error.isNotEmpty
                  ? ErrorRetryWidget(
                      message: provider.error,
                      onRetry: provider.loadCountries,
                    )
                  : ListView.builder(
                      itemCount: provider.filteredCountries.length,
                      itemBuilder: (_, index) {
                        return CountryCard(
                          country: provider.filteredCountries[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ///Region Filter
  void _showRegionFilter(BuildContext context) {
    final provider = context.read<CountryProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Region',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: provider.selectedRegion,
                items: provider.regions
                    .map(
                      (region) =>
                          DropdownMenuItem(value: region, child: Text(region)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.filterByRegion(value);
                    Navigator.pop(context);
                  }
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        );
      },
    );
  }
}
