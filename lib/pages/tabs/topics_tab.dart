import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studybuddy/models/quiz.dart';
import 'package:studybuddy/services/user_quizzes.dart';
import 'package:studybuddy/pages/quiz_page.dart';

class TopicsTab extends StatefulWidget {
  final Future<String> role;
  const TopicsTab({super.key, required this.role});

  @override
  _TopicsTabState createState() => _TopicsTabState();
}

class _TopicsTabState extends State<TopicsTab> {
  List<Quiz> _allTopics = [];
  List<Quiz> _filteredTopics = [];

  void _getTopics() async {
    final topics = await UserQuizzes().getQuizzes();
    setState(() {
      _allTopics = topics;
      _filteredTopics = List.from(_allTopics);
    });
  }

  @override
  void initState() {
    super.initState();
    _getTopics();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTopics = List.from(_allTopics);
      } else {
        _filteredTopics = _allTopics
            .where((topic) => topic.docId
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _refreshTopics() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _getTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String? query = await showSearch<String>(
                context: context,
                delegate: _SearchDelegate(),
              );
              if (query != null) {
                _onSearch(query);
              }
            },
          ),
        ],
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTopics,
        child: ListView.builder(
          itemCount: _filteredTopics.length,
          itemBuilder: (context, index) {
            final topic = _filteredTopics[index];
            return FutureBuilder<String>(
              future: widget.role,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                } else if (snapshot.hasError) {
                  return const ListTile(
                    title: Text('Error loading role'),
                  );
                } else if (snapshot.data == 'teacher') {
                  return Dismissible(
                    key: Key(topic.docId),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        _filteredTopics.removeAt(index);
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Topic'),
                            content: const Text(
                                'Are you sure you want to delete this topic?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  if (topic.docId != null) {
                                    UserQuizzes().deleteQuiz(topic.docId!);
                                  }
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        '${topic.docId.toString()} deleted'),
                                  ));
                                },
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _filteredTopics.insert(index, topic);
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text(topic.docId.toString()),
                      onTap: () {
                        if (snapshot.data == 'student') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(topic.docId),
                            ),
                          ).then((_) {
                            _getTopics();
                          });
                        } else if (snapshot.data == 'teacher') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Topic Details'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Prompt: ${topic.prompt}'),
                                    Text('Difficulty: ${topic.difficulty}'),
                                    Text('Code: ${topic.docId}'),
                                    Text(
                                        'Number of Questions: ${topic.number}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: topic.docId),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${topic.docId} copied to clipboard'),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  );
                } else {
                  return ListTile(
                    title: Text(topic.docId),
                    trailing: FutureBuilder(
                      future: UserQuizzes().getScore(topic.docId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading...');
                        } else if (snapshot.hasError) {
                          return const Text('Error loading score');
                        } else {
                          return CircleAvatar(
                            child: Text(snapshot.data.toString()),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(topic.docId),
                        ),
                      ).then((_) {
                        _getTopics();
                      });
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          close(context, '');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(query.isNotEmpty
          ? 'Search results for "$query"'
          : 'Start typing to search'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text(query.isNotEmpty
          ? 'Search suggestions for "$query"'
          : 'Start typing to search'),
    );
  }

  @override
  void showResults(BuildContext context) {
    close(context, query);
  }
}
