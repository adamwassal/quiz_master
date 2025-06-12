import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/firestore.dart';
import 'package:quiz_master/core/widgets/quizCard.dart';
import 'package:quiz_master/features/QuizReviewScreen/quiz_review_screen.dart';
import 'package:quiz_master/features/QuizScreen/quizScreen.dart';


class CategoryScreen extends StatelessWidget {
  final String primaryColor;
  final int quizesTotal;
  final String title;
  final List<String> quizesIDs;

  const CategoryScreen({
    super.key,
    required this.primaryColor,
    required this.quizesTotal,
    required this.title,
    required this.quizesIDs,
  });

  @override
  Widget build(BuildContext context) {
    final fireStoreService = FireStoreService();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    Color color;
    try {
      color = Color(int.parse(primaryColor.replaceFirst('#', ''), radix: 16) | 0xFF000000);
    } catch (e) {
      color = Theme.of(context).primaryColor;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: color,
      ),
      body: userId.isEmpty
          ? const Center(child: Text('Please sign in to view quizzes'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title Quizzes',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$quizesTotal ${quizesTotal == 1 ? 'Quiz' : 'Quizzes'} Available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: fireStoreService.getQuizzesByIDs(quizesIDs),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading quizzes'));
                        }
                        final quizzes = snapshot.data?.docs ?? [];
                        if (quizzes.isEmpty) {
                          return const Center(child: Text('No quizzes available'));
                        }

                        return ListView.builder(
                          itemCount: quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = quizzes[index].data() as Map<String, dynamic>;
                            final quizId = quizzes[index].id;
                            final quizTitle = quiz['title'] as String? ?? 'Untitled';
                            final totalQuestions = (quiz['total_questions'] as num?)?.toInt() ?? 0;

                            return FutureBuilder<bool>(
                              future: fireStoreService.hasUserPlayedQuiz(userId: userId, quizId: quizId),
                              builder: (context, playedSnapshot) {
                                if (playedSnapshot.connectionState == ConnectionState.waiting) {
                                  return const ListTile(
                                    title: CircularProgressIndicator(),
                                  );
                                }

                                final hasPlayed = playedSnapshot.data ?? false;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: QuizCard(
                                    quizName: quizTitle,
                                    timeAgo: 'Total Questions: $totalQuestions',
                                    percentage: 0, // Not shown for unplayed quizzes
                                    score: hasPlayed ? 'View Score' : 'Start Quiz',
                                    accentColor: color,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => hasPlayed
                                              ? QuizReviewScreen(
                                                  quizId: quizId,
                                                  category: quizTitle,
                                                )
                                              : QuizScreen(
                                                  quizId: quizId,
                                                  category: quizTitle,
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}