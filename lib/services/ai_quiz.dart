import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkersAI {
  final String baseUrl;
  final String apiKey;

  WorkersAI({required this.baseUrl, required this.apiKey});

  static Future<WorkersAI> create(FirebaseFirestore firestore) async {
    final configSnapshot =
        await firestore.collection('config').doc('workers').get();

    if (configSnapshot.exists && configSnapshot.data() != null) {
      final configData = configSnapshot.data()!;
      final apiKey = configData['apiKey'];
      final baseUrl = configData['baseUrl'];

      return WorkersAI(
        baseUrl: baseUrl,
        apiKey: apiKey,
      );
    } else {
      throw Exception("WorkersAI config not found");
    }
  }

  Future<List<Map<String, dynamic>>> generateQuiz(
      String topic, String difficulty, int number) async {
    try {
      final uri = Uri.parse(baseUrl);

      final payload = {
        "prompt": '''
Generate $number quizzes on the topic "$topic" at a "$difficulty" difficulty level. Ensure that:
1. Each quiz contains a valid question, four unique and logical options, and one correct answer.
2. The correct answer must be accurate, logically consistent with the question, and clearly identified.
3. The correct answer must exactly match one of the provided options in text and capitalization.
4. All questions and options must be text-based and clearly written. Avoid non-text-based or ambiguous content.
5. Return the response in the following valid JSON format, without any additional text or formatting:
[
  {
    "question": "Sample question?",
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
    "correct": "Option 2"
  }
]
6. Ensure that the provided correct answer is written as is and not as a letter or other shorthand (e.g., "A", "B", etc.).
7. Verify that the question and its options are coherent, accurate, and aligned with the specified difficulty level.
''',
      };

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true &&
            responseBody['result']['response'] != null) {
          final jsonString = responseBody['result']['response'];
          final parsedJson = jsonDecode(jsonString);

          if (parsedJson is List) {
            return List<Map<String, dynamic>>.from(parsedJson);
          } else {
            throw Exception("Invalid JSON format received: $jsonString");
          }
        } else {
          throw Exception(
              "API response indicates failure or missing 'response': ${response.body}");
        }
      } else {
        throw Exception(
            "Failed to get a response: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      throw Exception("Error occurred during quiz generation: $e");
    }
  }
}
