import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8E7CC3),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// LOGO
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/outer_logo.png',
                      width: 220,
                    ),
                  ),

                  Image.asset('assets/images/inner_logo.png', width: 130),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //APP NAME
            const Text(
              "Country",
              style: TextStyle(
                fontFamily: "GreatVibes",
                fontSize: 46,
                color: Colors.white,
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 160,
              height: 1.2,
              color: Colors.white.withOpacity(0.9),
            ),

            const Text(
              "EXPLORER",
              style: TextStyle(
                fontFamily: "PlayfairDisplay",
                fontSize: 26,
                letterSpacing: 4,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
