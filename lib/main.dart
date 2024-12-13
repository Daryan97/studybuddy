import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studybuddy/pages/home_page.dart';
import 'package:studybuddy/pages/login_page.dart';
import 'package:studybuddy/pages/register_page.dart';
import 'package:studybuddy/pages/tabs/add_tab.dart';
import 'package:studybuddy/pages/tabs/profile_tab.dart';
import 'package:studybuddy/pages/tabs/topics_tab.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn() ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/add': (context) => const AddTab(),
        '/topics': (context) => TopicsTab(),
        '/profile': (context) => ProfileTab(),
      },
    );
  }
}