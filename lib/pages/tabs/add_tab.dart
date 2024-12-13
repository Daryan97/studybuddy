import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddTab extends StatefulWidget {
  const AddTab({super.key});

  @override
  State<AddTab> createState() => _AddTabState();
}

class _AddTabState extends State<AddTab> {
  double _difficultyValue = 1;

  String getDifficultyLabel(double value) {
    if (value == 1) return 'Easy';
    if (value == 2) return 'Medium';
    return 'Hard';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Topic',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Topic',
                border: OutlineInputBorder(),
              ),
            ),
            const Text(
              'Topic you want to study',
              style: TextStyle(color: Colors.grey),
            ),
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
              decoration: const InputDecoration(
                labelText: 'Number of Questions',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
                FilteringTextInputFormatter.allow(RegExp(r'^[1-9]$|^10$')),
              ],
            ),
            const Text(
              'Maximum 10 questions',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
