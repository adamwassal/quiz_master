import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get quizes => _firestore.collection("quizes");
  CollectionReference get categories => _firestore.collection("categories");
  CollectionReference get users => _firestore.collection("users");

  Future<DocumentReference<Object?>> addQuiz({
    String? categoryName,
    String title = 'Untitled Quiz',
    String userId = '',
  }) async {
    final quizData = {
      "categoryName": categoryName,
      "correctAnswers": 0,
      "questions": [],
      "score": "0/0",
      "title": title,
      "total_questions": 0,
      "updateTime": FieldValue.serverTimestamp(),
      "creatorId": userId,
    };

    final docRef = await quizes.add(quizData);

    if (userId.isNotEmpty) {
      await addQuizToUser(userId, docRef.id);
    }

    return docRef;
  }

  Future<void> updateQuizScore({
    required String quizId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    return quizes.doc(quizId).update({
      "correctAnswers": correctAnswers,
      "score": "$correctAnswers/$totalQuestions",
      "total_questions": totalQuestions,
      "updateTime": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserScore({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    final updateData = {
      "totalScore": FieldValue.increment(score),
      "quizzesPlayed": FieldValue.arrayUnion([quizId]),
      "updateTime": FieldValue.serverTimestamp(),
      "quizScores.$quizId": "$score/$totalQuestions",
    };

    return users.doc(userId).set(updateData, SetOptions(merge: true));
  }

  Future<Map<String, String>> getUserQuizScores(String userId) async {
    final doc = await users.doc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final scores = data?['quizScores'] as Map<String, dynamic>?;
      return scores?.map((k, v) => MapEntry(k, v.toString())) ?? {};
    }
    return {};
  }

  Future<void> addQuizToUser(String userId, String quizId) async {
    return users.doc(userId).set({
      "quizzesCreated": FieldValue.arrayUnion([quizId]),
      "updateTime": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeQuizFromUser(String userId, String quizId) async {
    return users.doc(userId).update({
      "quizzesCreated": FieldValue.arrayRemove([quizId]),
      "updateTime": FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCategory({
    required String title,
    String icon = 'help_outline',
    String primaryColor = '#6366F1',
  }) async {
    await categories.add({
      "title": title,
      "totalQuizes": 0,
      "quizesIds": [],
      "icon": icon,
      "primaryColor": primaryColor,
      "updateTime": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getQuizesStream() {
    return quizes.orderBy("updateTime", descending: true).snapshots();
  }

  Stream<QuerySnapshot> getQuizzesByIDs(List<String> quizIDs) {
    if (quizIDs.isEmpty) return const Stream.empty();
    final limitedIDs = quizIDs.length > 10 ? quizIDs.sublist(0, 10) : quizIDs;
    return quizes.where(FieldPath.documentId, whereIn: limitedIDs).snapshots();
  }

  Stream<QuerySnapshot> getCategoriesStream() {
    return categories.orderBy("updateTime", descending: true).snapshots();
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return users.doc(userId).snapshots();
  }

  Future<void> saveQuizResult({
    required String userId,
    required String quizId,
    required String title,
    required int correctAnswers,
    required int totalQuestions,
    List<int?>? userAnswers,
  }) async {
    final score = "$correctAnswers/$totalQuestions";
    final answersToSave = userAnswers ?? List<int?>.filled(totalQuestions, null); // Default to null-filled list

    await users
        .doc(userId)
        .collection("playedQuizzes")
        .doc(quizId)
        .set({
          "quizId": quizId,
          "title": title,
          "score": score,
          "timestamp": FieldValue.serverTimestamp(),
          "userAnswers": answersToSave, // Ensure userAnswers is always set
        });
  }

  Future<List<DocumentSnapshot>> getUserPlayedQuizzes(String userId) async {
    final snapshot = await users
        .doc(userId)
        .collection("playedQuizzes")
        .orderBy("timestamp", descending: true)
        .limit(5)
        .get();

    return snapshot.docs;
  }

  Future<void> deleteQuiz(String quizId) => quizes.doc(quizId).delete();
  Future<void> deleteCategory(String categoryId) => categories.doc(categoryId).delete();

  Future<void> resetQuiz({required String userId, required String quizId}) async {
    await users.doc(userId).collection("playedQuizzes").doc(quizId).delete();
  }

  Future<bool> hasUserPlayedQuiz({required String userId, required String quizId}) async {
    final doc = await users.doc(userId).collection("playedQuizzes").doc(quizId).get();
    return doc.exists;
  }
}