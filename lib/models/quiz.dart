class Quiz {
  final dynamic docId;
  final String difficulty;
  final int number;
  final String prompt;
  final dynamic score;

  Quiz({
    required this.docId,
    required this.difficulty,
    required this.number,
    required this.prompt,
    this.score = 0,
  });

  factory Quiz.fromMap(Map<String, dynamic> data, dynamic docId) {
    return Quiz(
      docId: docId,
      difficulty: data['difficulty'],
      number: int.parse(data['number'].toString()),
      prompt: data['prompt'],
      score: data['score'],
    );
  }
}

class QuizItem {
  final String question;
  final List<String> options;
  final String answer;

  QuizItem({
    required this.question,
    required this.answer,
    required this.options,
  });

  factory QuizItem.fromMap(Map<String, dynamic> data) {
    return QuizItem(
      question: data['question'],
      answer: data['answer'],
      options: List<String>.from(data['options']),
    );
  }
}
