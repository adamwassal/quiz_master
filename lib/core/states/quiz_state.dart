import 'package:flutter/material.dart';

class QuizState extends ChangeNotifier {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  List<int?> _userAnswers = [];
  bool _isTimerRunning = false;
  int _timeLeft = 60; // Default, will be updated from Firestore

  int get currentIndex => _currentIndex;
  int get correctAnswers => _correctAnswers;
  List<int?> get userAnswers => _userAnswers;
  bool get isTimerRunning => _isTimerRunning;
  int get timeLeft => _timeLeft;

  void initialize(int questionCount, int timerDuration) {
    _userAnswers = List<int?>.filled(questionCount, null, growable: true);
    _timeLeft = timerDuration;
    _currentIndex = 0;
    _correctAnswers = 0;
    notifyListeners();
  }

  void answerQuestion(int selectedIndex, int correctIndex) {
    _userAnswers[_currentIndex] = selectedIndex;
    if (selectedIndex == correctIndex) {
      _correctAnswers++;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _userAnswers.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void startTimer(VoidCallback onTick) {
    _isTimerRunning = true;
    notifyListeners();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isTimerRunning || _timeLeft <= 0) return false;
      _timeLeft--;
      onTick();
      notifyListeners();
      return true;
    });
  }

  void pauseTimer() {
    _isTimerRunning = false;
    notifyListeners();
  }

  void resetTimer(int duration) {
    _timeLeft = duration;
    _isTimerRunning = false;
    notifyListeners();
  }

  void completeQuiz() {
    _isTimerRunning = false;
    notifyListeners();
  }
}