import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studybuddy/models/quiz.dart';
import 'package:studybuddy/pages/quiz_page.dart';
import 'package:studybuddy/services/ai_quiz.dart';
import 'package:studybuddy/services/user_quizzes.dart';

class AddTab extends StatefulWidget {
  final Future<String> role;

  const AddTab({super.key, required this.role});

  @override
  State<AddTab> createState() => _AddTabState();
}

class _AddTabState extends State<AddTab> {
  double _difficultyValue = 1;
  late final WorkersAI _ai;
  final _topicController = TextEditingController();
  final _numberController = TextEditingController();
  final _quizCodeController = TextEditingController();
  String? role;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _fetchRole();
  }

  Future<void> _initializeAI() async {
    _ai = await WorkersAI.create(FirebaseFirestore.instance);
  }

  Future<void> _fetchRole() async {
    try {
      role = await widget.role;
      setState(() {});
    } catch (e) {
      throw Exception('Error fetching role: $e');
    }
  }

  String getDifficultyLabel(double value) {
    if (value == 1) return 'Easy';
    if (value == 2) return 'Medium';
    return 'Hard';
  }

  Future<void> _startQuiz() async {
    if (role == null) {
      throw Exception('Role not found');
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      if (role == 'student') {
        final quizCode = _quizCodeController.text.trim();

        final Quiz? quiz = await UserQuizzes().joinQuiz(quizCode);

        if (quiz != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(quizCode),
            ),
          );
        } else {
          throw Exception('Quiz not found');
        }
      } else if (role == 'teacher') {
        final topic = _topicController.text.trim();
        final difficulty = getDifficultyLabel(_difficultyValue);
        final number = int.tryParse(_numberController.text.trim()) ?? 1;

        final response = await _ai.generateQuiz(topic, difficulty, number);
        final newQuiz = await UserQuizzes().addQuiz(topic, difficulty, number);

        if (newQuiz.docId != null) {
          for (var item in response) {
            QuizItem quiz = QuizItem(
              question: item['question'] as String,
              options: List<String>.from(item['options']),
              answer: item['correct'] as String,
            );
            await UserQuizzes().addQuizItem(newQuiz.docId, quiz);
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quiz Code'),
              content: Text('Your quiz code is ${newQuiz.docId}'),
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
        } else {
          throw Exception('Error adding quiz');
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == 'student' ? 'Enter Quiz Code' : 'Add Topic',
        ),
        centerTitle: true,
      ),
      body: role == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role == 'student')
                    TextField(
                      controller: _quizCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Code',
                        border: OutlineInputBorder(),
                      ),
                    )
                  else ...[
                    TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const Text('Topic you want to study',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16.0),
                    const Text('Difficulty'),
                    Slider(
                      value: _difficultyValue,
                      min: 1,
                      max: 3,
                      divisions: 2,
                      label: getDifficultyLabel(_difficultyValue),
                      onChanged: (value) {
                        setState(() {
                          _difficultyValue = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Questions',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[1-9]$|^10$')),
                      ],
                    ),
                    const Text('Maximum 10 questions',
                        style: TextStyle(color: Colors.grey)),
                  ],
                  const SizedBox(height: 16.0),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: _startQuiz,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
