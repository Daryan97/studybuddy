import 'package:studybuddy/models/quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserQuizzes {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Quiz>> getQuizzes() async {
    List<Quiz> quizzes = [];
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userQuizzesSnapshot = await _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .collection('quizzes')
            .get();
        for (var quizDoc in userQuizzesSnapshot.docs) {
          quizzes.add(Quiz.fromMap(quizDoc.data(), quizDoc.id));
        }
      }
    } catch (e) {
      print("Error getting user quizzes: $e");
    }
    return quizzes;
  }

  Future<List<QuizItem>> getQuizItems(dynamic docId) async {
    List<QuizItem> quizItems = [];
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userQuizItemsSnapshot = await _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .collection('quizzes')
            .doc(docId)
            .collection("quiz")
            .get();
        for (var quizItemDoc in userQuizItemsSnapshot.docs) {
          quizItems.add(QuizItem.fromMap(quizItemDoc.data()));
        }
      }
    } catch (e) {
      print("Error getting user quiz items: $e");
    }
    return quizItems;
  }

  Future<Quiz> addQuiz(String prompt, String difficulty, int number) async {
    DocumentReference newQuiz;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        newQuiz = await _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .collection('quizzes')
            .add({
          'difficulty': difficulty,
          'number': number,
          'prompt': prompt,
        });

        return Quiz(
          docId: newQuiz.id,
          difficulty: difficulty,
          number: number,
          prompt: prompt,
        );
      }
    } catch (e) {
      print("Error adding quiz: $e");
    }

    return Quiz(
      docId: null,
      difficulty: difficulty,
      number: number,
      prompt: prompt,
    );
  }

  Future<void> addQuizItem(String docId, QuizItem quizItem) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final quizCollection = _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .collection('quizzes')
            .doc(docId)
            .collection('quiz');

        await quizCollection.add({
          'question': quizItem.question,
          'answer': quizItem.answer,
          'options': quizItem.options,
        });

        print("Quiz item added successfully!");
      } else {
        print("No authenticated user found.");
      }
    } catch (e) {
      print("Error adding quiz item: $e");
    }
  }

  Future<void> deleteQuiz(dynamic docId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .collection('quizzes')
            .doc(docId)
            .delete();
      }
    } catch (e) {
      print("Error deleting quiz: $e");
    }
  }

  Future<int> submitScore(dynamic docId, int score) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .collection('quizzes')
            .doc(docId)
            .update({'score': score});
        return score;
      }
    } catch (e) {
      print("Error submitting score: $e");
    }
    return 0;
  }
}
