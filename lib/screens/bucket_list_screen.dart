import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../controllers/bucketlist_provider.dart';

class BucketListScreen extends StatelessWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bucketProvider = context.watch<BucketListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bucket List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Alphabetical') {
                bucketProvider.sortAlphabetical();
              } else if (value == 'By Region') {
                bucketProvider.sortByRegion();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'Alphabetical',
                child: Text('Sort Alphabetically'),
              ),
              PopupMenuItem(value: 'By Region', child: Text('Sort by Region')),
            ],
          ),
        ],
      ),
      body: bucketProvider.bucketList.isEmpty
          ? const Center(
              child: Text(
                'No destinations in your bucket list.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bucketProvider.bucketList.length,
              itemBuilder: (context, index) {
                final country = bucketProvider.bucketList[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 120,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            country['image'] != null &&
                                    country['image'].isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: country['image'],
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: const Color.fromARGB(
                                        255,
                                        60,
                                        60,
                                        60,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Image.asset(
                                      'assets/images/default_flag.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/default_flag.jpg',
                                    fit: BoxFit.cover,
                                  ),

                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CONTENT
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      country['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      country['region'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        bucketProvider.remove(country['name']),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 22,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 22,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
