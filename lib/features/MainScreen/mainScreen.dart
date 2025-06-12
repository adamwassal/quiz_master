import 'package:flutter/material.dart';
import 'package:quiz_master/features/CategoriesPage/categoriesPage.dart';
import 'package:quiz_master/features/HomePage/homePage.dart';
import 'package:quiz_master/features/ProfilePage/profilePage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ValueNotifier<int> tabNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    tabNotifier.addListener(() {
      setState(() {
        _currentIndex = tabNotifier.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      HomePage(tabNotifier: tabNotifier), // 👈 Pass notifier here
      const CategoriesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Master', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 0.3),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              print("Points tapped");
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.only(right: 30),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.sports_score, color: Colors.white),
                  SizedBox(width: 5),
                  Text("400 Points", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.category), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          tabNotifier.value = index; // 👈 Keep in sync
        },
      ),
    );
  }
}
