import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/firestore.dart';
import 'package:quiz_master/features/QuizScreen/quizScreen.dart';

class QuizReviewScreen extends StatelessWidget {
  final String quizId;
  final String category;

  const QuizReviewScreen({
    super.key,
    required this.quizId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final fireStoreService = FireStoreService();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('$category Review'), centerTitle: true),
      body: userId.isEmpty
          ? const Center(child: Text('Please sign in to view quiz review'))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: fireStoreService.quizes.doc(quizId).snapshots(),
                  builder: (context, quizSnapshot) {
                    if (quizSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (quizSnapshot.hasError) {
                      return const Center(
                        child: Text('Error loading quiz data'),
                      );
                    }
                    if (!quizSnapshot.hasData || !quizSnapshot.data!.exists) {
                      return const Center(child: Text('Quiz not found'));
                    }

                    final quizData =
                        quizSnapshot.data!.data() as Map<String, dynamic>;
                    final questions = List<Map<String, dynamic>>.from(
                      quizData['questions'] ?? [],
                    );

                    return StreamBuilder<DocumentSnapshot>(
                      stream: fireStoreService.users
                          .doc(userId)
                          .collection('playedQuizzes')
                          .doc(quizId)
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (userSnapshot.hasError) {
                          return const Center(
                            child: Text('Error loading user answers'),
                          );
                        }
                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                quizId: quizId,
                                category: category,
                              ),
                            ),
                          );
                          return const Center(
                            child: Text('No answers found for this quiz'),
                          );
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        final userAnswers =
                            userData['userAnswers'] as List<dynamic>? ?? [];
                        final score = userData['score'] as String? ?? '0/0';
                        final parts = score.split('/');
                        final correct = int.tryParse(parts[0]) ?? 0;
                        final total = int.tryParse(parts[1]) ?? 1;
                        final percentage = (correct / total * 100).round();

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Score: $score ($percentage%)',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await fireStoreService.resetQuiz(
                                        userId: userId,
                                        quizId: quizId,
                                      );
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => QuizScreen(
                                              quizId: quizId,
                                              category: category,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('Reset & Retake Quiz'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: questions.length,
                                itemBuilder: (context, index) {
                                  final question = questions[index];
                                  final questionText =
                                      question['text'] as String? ??
                                      'No question';
                                  final options = List<String>.from(
                                    question['options'] ?? [],
                                  );
                                  final correctAnswerIndex =
                                      question['correctAnswer'] as int? ?? 0;
                                  final userAnswerIndex =
                                      index < userAnswers.length
                                      ? userAnswers[index] as int?
                                      : null;

                                  print(
                                    'Debug - Question $index: userAnswerIndex = $userAnswerIndex, userAnswers = $userAnswers',
                                  ); // Debug log

                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Question ${index + 1}: $questionText',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ...List<Widget>.generate(
                                            options.length,
                                            (i) {
                                              final isCorrect =
                                                  i == correctAnswerIndex;
                                              final isUserAnswer =
                                                  userAnswerIndex != null &&
                                                  i == userAnswerIndex;
                                              final color = isCorrect
                                                  ? Colors.green.withOpacity(
                                                      0.2,
                                                    )
                                                  : isUserAnswer && !isCorrect
                                                  ? Colors.red.withOpacity(0.2)
                                                  : Colors.transparent;

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isCorrect
                                                        ? Colors.green
                                                        : isUserAnswer &&
                                                              !isCorrect
                                                        ? Colors.red
                                                        : Colors.grey[300]!,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: ListTile(
                                                  title: Text(options[i]),
                                                  trailing: isCorrect
                                                      ? const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                        )
                                                      : isUserAnswer
                                                      ? const Icon(
                                                          Icons.cancel,
                                                          color: Colors.red,
                                                        )
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Correct Answer: ${options[correctAnswerIndex]}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Your Answer: ${userAnswerIndex != null ? options[userAnswerIndex] : "Not answered"}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: userAnswerIndex != null
                                                  ? (userAnswerIndex ==
                                                            correctAnswerIndex
                                                        ? Colors.green
                                                        : Colors.red)
                                                  : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            userAnswerIndex ==
                                                    correctAnswerIndex
                                                ? 'Correct'
                                                : userAnswerIndex != null
                                                ? 'Incorrect'
                                                : 'Not answered',
                                            style: TextStyle(
                                              color:
                                                  userAnswerIndex ==
                                                      correctAnswerIndex
                                                  ? Colors.green
                                                  : userAnswerIndex != null
                                                  ? Colors.red
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }
}
