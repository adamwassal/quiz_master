import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quiz_master/features/AuthScreen/authScreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  final List<String> titles = [
    'Welcome to Quiz Master',
    'Test Your Knowledge',
    'Compete with Friends',
  ];


  final storage = FlutterSecureStorage();


  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF9333EA), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: PageView.builder(
          controller: _controller,
          itemCount: titles.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Quiz Master',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${titles[index]}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      if (index == titles.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 20,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              storage.write(key: 'onBoardingCompleted', value: 'true');
                              // Navigate to the login screen
                              Navigator.pushReplacement(context, 
                                MaterialPageRoute(
                                  builder: (context) => const AuthScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),

                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 30,
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 50,
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: titles.length,
                    effect: const WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      activeDotColor: Color.fromARGB(255, 255, 255, 255),
                      dotColor: Color(0xFFE5E7EB),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
