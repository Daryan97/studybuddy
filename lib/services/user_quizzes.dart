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
        final userRole =
            await _firestore.collection('user_roles').doc(user.uid).get();
        final role = userRole.data()?['role'];
        if (role == 'teacher') {
          final userQuizzesSnapshot = await _firestore
              .collection('user_quizzes')
              .doc(user.uid)
              .collection('quizzes')
              .get();
          for (var quizDoc in userQuizzesSnapshot.docs) {
            quizzes.add(Quiz.fromMap(quizDoc.data(), quizDoc.id));
          }
        } else {
          final userQuizzesSnapshot =
              await _firestore.collection('user_quizzes').get();
          for (var userDoc in userQuizzesSnapshot.docs) {
            final teacherUID = userDoc.id;
            final quizSnapshot = await _firestore
                .collection('user_quizzes')
                .doc(teacherUID)
                .collection('quizzes')
                .get();
            for (var quizDoc in quizSnapshot.docs) {
              quizzes.add(Quiz.fromMap(quizDoc.data(), quizDoc.id));
            }
          }
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
      final userQuizzesSnapshot =
          await _firestore.collection('user_quizzes').get();

      for (var userDoc in userQuizzesSnapshot.docs) {
        final teacherUID = userDoc.id;

        final quizSnapshot = await _firestore
            .collection('user_quizzes')
            .doc(teacherUID)
            .collection('quizzes')
            .doc(docId)
            .collection('quiz')
            .get();

        for (var quizItemDoc in quizSnapshot.docs) {
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

        await _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .set({'created': true}, SetOptions(merge: true));

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
        final quizItemsSnapshot = await _firestore
            .collection('user_quizzes')
            .doc(user.uid)
            .collection('quizzes')
            .doc(docId)
            .collection('quiz')
            .get();

        for (var quizItemDoc in quizItemsSnapshot.docs) {
          await quizItemDoc.reference.delete();
        }

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

  Future<Quiz?> joinQuiz(String code) async {
    try {
      final userQuizzesSnapshot =
          await _firestore.collection('user_quizzes').get();

      for (var userDoc in userQuizzesSnapshot.docs) {
        final teacherUID = userDoc.id;

        final quizSnapshot = await _firestore
            .collection('user_quizzes')
            .doc(teacherUID)
            .collection('quizzes')
            .where(FieldPath.documentId, isEqualTo: code)
            .get();

        if (quizSnapshot.docs.isNotEmpty) {
          final quizData = quizSnapshot.docs.first.data();

          print("Teacher UID: $teacherUID");
          print("Quiz ID: ${quizSnapshot.docs.first.id}");

          await _firestore
              .collection('user_quizzes')
              .doc(teacherUID)
              .collection('quizzes')
              .doc(quizSnapshot.docs.first.id)
              .collection('participants')
              .doc(_auth.currentUser!.uid)
              .set({'score': ''});

          return Quiz.fromMap(quizData, quizSnapshot.docs.first.id);
        }
      }
    } catch (e) {
      print("Error joining quiz: $e");
    }
    return null;
  }

  Future<int> submitScore(dynamic docId, int score) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userQuizzesSnapshot =
            await _firestore.collection('user_quizzes').get();

        for (var userDoc in userQuizzesSnapshot.docs) {
          final teacherUID = userDoc.id;

          final quizSnapshot = await _firestore
              .collection('user_quizzes')
              .doc(teacherUID)
              .collection('quizzes')
              .doc(docId)
              .collection('participants')
              .doc(user.uid)
              .update({'score': score});
        }
        return score;
      }
    } catch (e) {
      print("Error submitting score: $e");
    }
    return 0;
  }

  Future<int> getScore(dynamic docId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userQuizzesSnapshot =
            await _firestore.collection('user_quizzes').get();

        for (var userDoc in userQuizzesSnapshot.docs) {
          final teacherUID = userDoc.id;

          final quizSnapshot = await _firestore
              .collection('user_quizzes')
              .doc(teacherUID)
              .collection('quizzes')
              .doc(docId)
              .collection('participants')
              .doc(user.uid)
              .get();

          if (quizSnapshot.exists) {
            final score = quizSnapshot.data()?['score'];
            return score;
          }
        }
      }
    } catch (e) {
      print("Error getting score: $e");
    }
    return 0;
  }
}
