import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/firestore.dart';
import 'package:quiz_master/core/widgets/categoryCard.dart';
import 'package:quiz_master/core/widgets/quizCard.dart';
import 'package:quiz_master/features/CategoryScreen/categoryScreen.dart';
import 'package:quiz_master/features/QuizReviewScreen/quiz_review_screen.dart';

class HomePage extends StatelessWidget {
  final ValueNotifier<int>? tabNotifier;

  const HomePage({super.key, this.tabNotifier});

  @override
  Widget build(BuildContext context) {
    final fireStoreService = FireStoreService();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return const Center(child: Text('Please sign in to continue'));
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => tabNotifier?.value = 1,
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: fireStoreService.getCategoriesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text("Error loading categories");
                    }
                    final cats = snapshot.data?.docs ?? [];
                    if (cats.isEmpty) {
                      return const Text("No categories available");
                    }
                    return SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cats.length >= 4 ? 4 : cats.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) {
                          final data = cats[i].data() as Map<String, dynamic>;
                          return CategoryCard(
                            icon: data['icon'] as String? ?? "category",
                            categoryName: data['title'] as String? ?? "No Title",
                            quizCount: (data['totalQuizes'] as num?)?.toInt() ?? 0,
                            primaryColor: data['primaryColor'] as String? ?? "#6366F1",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryScreen(
                                    primaryColor: data['primaryColor'] as String? ?? "#6366F1",
                                    quizesTotal: (data['totalQuizes'] as num?)?.toInt() ?? 0,
                                    title: data['title'] as String? ?? "No Title",
                                    quizesIDs: List<String>.from(data['quizesIds'] ?? []),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Recent Scores Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Scores",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implement view all scores functionality
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: fireStoreService
                      .users
                      .doc(userId)
                      .collection("playedQuizzes")
                      .orderBy("timestamp", descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text("Error loading quizzes");
                    }
                    final quizzes = snapshot.data?.docs ?? [];
                    if (quizzes.isEmpty) {
                      return const Text("You haven't played any quiz yet.");
                    }
                    return Column(
                      children: quizzes.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        final title = d['title'] as String? ?? "Untitled";
                        final score = d['score'] as String? ?? "0/0";
                        final parts = score.split('/');
                        final correct = int.tryParse(parts[0]) ?? 0;
                        final total = int.tryParse(parts[1]) ?? 1;
                        final percent = (correct / total * 100).round().toDouble();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: QuizCard(
                            quizName: title,
                            timeAgo: "Recently",
                            percentage: percent,
                            score: score,
                            accentColor: percent >= 70
                                ? Colors.green
                                : percent >= 50
                                    ? Colors.orange
                                    : Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizReviewScreen(
                                    quizId: doc.id,
                                    category: title,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}