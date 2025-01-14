import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studybuddy/models/quiz.dart';
import 'package:studybuddy/services/user_quizzes.dart';

class QuizPage extends StatefulWidget {
  final dynamic docId;
  const QuizPage(this.docId, {super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizItem> quizItems = [];
  bool isLoading = true;
  List<String> selectedAnswers = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getQuizItems();
  }

  Future<void> getQuizItems() async {
    quizItems = await UserQuizzes().getQuizItems(widget.docId);

    setState(() {
      isLoading = false;
    });
  }

  void nextQuestion() {
    if (selectedAnswers.length <= currentIndex || selectedAnswers[currentIndex].isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Option Selected'),
          content: const Text('Please select an option before proceeding.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (currentIndex < quizItems.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      int score = 0;
      for (int i = 0; i < quizItems.length; i++) {
        if (quizItems[i].answer == selectedAnswers[i]) {
          score++;
        }
      }
      score = (score / quizItems.length * 100).round();

      UserQuizzes().submitScore(widget.docId, score);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Completed'),
          content: Text('You have completed the quiz, and you have got a score of $score%.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: Text(
                          '${currentIndex + 1}/${quizItems.length}: ${quizItems[currentIndex].question}'),
                      subtitle: Column(
                        children: quizItems[currentIndex]
                            .options
                            .map((option) => RadioListTile(
                                  title: Text(option),
                                  value: option,
                                  groupValue: selectedAnswers.length > currentIndex
                                      ? selectedAnswers[currentIndex]
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      if (selectedAnswers.length > currentIndex) {
                                        selectedAnswers[currentIndex] = value as String;
                                      } else {
                                        selectedAnswers.add(value as String);
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: nextQuestion,
                    child: Text(currentIndex == quizItems.length - 1 ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
    );
  }
}
