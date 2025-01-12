import 'package:flutter/material.dart';
import 'package:studybuddy/pages/tabs/add_tab.dart';
import 'package:studybuddy/pages/tabs/profile_tab.dart';
import 'package:studybuddy/pages/tabs/topics_tab.dart';
import 'package:studybuddy/services/user_role.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
        FocusScope.of(context).unfocus();
      });
    }
  }

  Future<String> getRole() async {
    UserRole userRole = UserRole();
    return await userRole.getUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TopicsTab(key: PageStorageKey('TopicsTab'), role: getRole(),),
          AddTab(key: PageStorageKey('AddTab'), role: getRole(),),
          ProfileTab(key: PageStorageKey('ProfileTab')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Topics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 50), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
