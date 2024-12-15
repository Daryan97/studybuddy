import 'package:flutter/material.dart';

class TopicsTab extends StatefulWidget {
  const TopicsTab({super.key});

  @override
  _TopicsTabState createState() => _TopicsTabState();
}

class _TopicsTabState extends State<TopicsTab> {
  final List<Map<String, dynamic>> _allTopics = [
    {'name': 'Topic 1', 'score': 70},
    {'name': 'Topic 2', 'score': 85},
    {'name': 'Topic 3', 'score': 50},
    {'name': 'Topic 4', 'score': 90},
    {'name': 'Topic 5', 'score': 65},
  ];
  List<Map<String, dynamic>> _filteredTopics = [];

  @override
  void initState() {
    super.initState();
    _filteredTopics = List.from(_allTopics);
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTopics = List.from(_allTopics);
      } else {
        _filteredTopics = _allTopics
            .where((topic) =>
                topic['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _refreshTopics() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Refresh screen
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
            return Dismissible(
              key: Key(topic['name']),
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${topic['name']} deleted'),
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
                title: Text(topic['name']),
                trailing: CircleAvatar(
                  backgroundColor: topic['score'] < 60
                      ? Colors.red
                      : topic['score'] < 80
                          ? Colors.orange
                          : Colors.green,
                  foregroundColor: Colors.white,
                  child: Text('${topic['score'].toString()}%'),
                ),
              ),
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
