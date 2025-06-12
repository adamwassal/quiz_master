import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/firestore.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String category;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.category,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FireStoreService _fireStoreService = FireStoreService();
  late Stream<DocumentSnapshot> _quizStream;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalScore = 0;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  bool _isSubmitted = false;
  int? _selectedAnswerIndex;
  int _timeRemaining = 60;
  late Timer _timer;
  bool _showResult = false;
  List<int?> _userAnswers = []; // Store user's selected answers

  @override
  void initState() {
    super.initState();
    _resetState();
    _loadQuizData();
    _startTimer();
  }

  void _resetState() {
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _totalScore = 0;
      _isSubmitted = false;
      _selectedAnswerIndex = null;
      _userAnswers = [];
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadQuizData() {
    _quizStream = _fireStoreService.quizes.doc(widget.quizId).snapshots();
    _quizStream.listen((snapshot) {
      if (!mounted) return;
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
          if (_userAnswers.isEmpty) {
            _userAnswers = List<int?>.filled(_questions.length, null); // Initialize only if empty
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quiz: $error')),
      );
      setState(() => _isLoading = false);
    });
  }

  int _parseScore(dynamic scoreData) {
    if (scoreData == null) return 0;
    final parts = scoreData.toString().split('/');
    return int.tryParse(parts[0]) ?? 0;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer.cancel();
        if (!_isSubmitted) {
          _skipQuestion();
        }
      }
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() => _timeRemaining = 60);
    _startTimer();
  }

  void _answerQuestion(int selectedIndex) {
    if (_isSubmitted || _questions.isEmpty) return;

    final correctIndex = _questions[_currentIndex]['correctAnswer'] as int;
    final isCorrect = selectedIndex == correctIndex;

    setState(() {
      _selectedAnswerIndex = selectedIndex;
      if (_userAnswers.length <= _currentIndex) {
        _userAnswers.add(selectedIndex); // Extend list if needed
      } else {
        _userAnswers[_currentIndex] = selectedIndex; // Update existing index
      }
      _isSubmitted = true;
      if (isCorrect) {
        _correctAnswers++;
        _totalScore += 100;
      }
    });

    _updateFirestoreScore(); // Save immediately after answer

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        _nextQuestion();
      } else {
        _completeQuiz();
      }
    });
  }

  void _updateFirestoreScore() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    // Ensure userAnswers matches the number of questions without reinitializing
    while (_userAnswers.length < _questions.length) {
      _userAnswers.add(null); // Pad with nulls if list is shorter
    }

    print('Saving userAnswers: $_userAnswers'); // Debug log
    _fireStoreService.saveQuizResult(
      userId: userId,
      quizId: widget.quizId,
      title: widget.category,
      correctAnswers: _correctAnswers,
      totalQuestions: _questions.length,
      userAnswers: _userAnswers,
    );

    _fireStoreService.quizes.doc(widget.quizId).update({
      'correctAnswers': _correctAnswers,
      'score': '$_totalScore/${_questions.length * 100}',
      'updateTime': FieldValue.serverTimestamp(),
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    setState(() {
      _currentIndex++;
      _isSubmitted = false;
      _selectedAnswerIndex = null;
      _resetTimer();
    });
  }

  void _skipQuestion() {
    if (_questions.isEmpty || _currentIndex >= _questions.length - 1) {
      _completeQuiz();
      return;
    }
    setState(() {
      if (_userAnswers.length <= _currentIndex) {
        _userAnswers.add(null); // Extend list if needed
      } else {
        _userAnswers[_currentIndex] = null; // Mark as skipped
      }
    });
    _updateFirestoreScore(); // Save after skip
    _nextQuestion();
  }

  void _completeQuiz() {
    _timer.cancel();
    _updateFirestoreScore(); // Final save with all answers
    setState(() => _showResult = true);
  }

  Color _getOptionColor(int optionIndex) {
    if (!_isSubmitted) return Colors.transparent;

    final correctIndex = _questions[_currentIndex]['correctAnswer'] as int;

    if (optionIndex == correctIndex) {
      return Colors.green.withOpacity(0.2);
    } else if (optionIndex == _selectedAnswerIndex) {
      return Colors.red.withOpacity(0.2);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return QuizResultScreen(
        score: _totalScore,
        totalQuestions: _questions.length,
        correctAnswers: _correctAnswers,
        onRestart: () {
          if (!mounted) return;
          _resetState();
          _loadQuizData();
          _startTimer();
        },
        onExit: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Score: $_totalScore',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading || _questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1}/${_questions.length}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${((_currentIndex + 1) / _questions.length * 100).round()}% Complete',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _questions.isNotEmpty
                          ? (_currentIndex + 1) / _questions.length
                          : 0,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).primaryColor,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 16),

                    // Category and timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.category,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Question
                    Text(
                      _questions[_currentIndex]['text'] ?? 'No question available',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Answer options
                    Expanded(
                      child: ListView.builder(
                        itemCount: (_questions[_currentIndex]['options'] as List?)?.length ?? 0,
                        itemBuilder: (context, index) {
                          final option = _questions[_currentIndex]['options'][index] as String? ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              color: _getOptionColor(index),
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  option,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: _isSubmitted && index == _selectedAnswerIndex
                                        ? (_selectedAnswerIndex == _questions[_currentIndex]['correctAnswer']
                                            ? Colors.green
                                            : Colors.red)
                                        : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                ),
                                onTap: _isSubmitted ? null : () => _answerQuestion(index),
                                trailing: _isSubmitted
                                    ? Icon(
                                        index == _questions[_currentIndex]['correctAnswer']
                                            ? Icons.check_circle
                                            : index == _selectedAnswerIndex
                                                ? Icons.cancel
                                                : null,
                                        color: index == _questions[_currentIndex]['correctAnswer']
                                            ? Colors.green
                                            : Colors.red,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatBox('Correct', _correctAnswers, Colors.green),
                          _buildStatBox('Wrong', _currentIndex - _correctAnswers, Colors.red),
                          _buildStatBox('Remaining', _questions.length - (_currentIndex + 1), Colors.grey),
                        ],
                      ),
                    ),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _skipQuestion,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: Colors.grey[300],
                          ),
                          child: const Text(
                            'Skip Question',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isSubmitted
                              ? (_currentIndex < _questions.length - 1
                                  ? _nextQuestion
                                  : _completeQuiz)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            _currentIndex < _questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatBox(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;
    final maxScore = totalQuestions * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz Completed!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).primaryColor,
                      semanticsLabel: 'Progress',
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '$score/$maxScore points',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              _buildResultRow('Correct Answers', '$correctAnswers/$totalQuestions'),
              _buildResultRow('Wrong Answers', '${totalQuestions - correctAnswers}/$totalQuestions'),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRestart,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Restart Quiz'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onExit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        'Exit Quiz',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}