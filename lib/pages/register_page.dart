import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String role = 'student';

  void dialogBox(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> register() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      if (!emailController.text.contains('@')) {
        Navigator.of(context).pop();
        dialogBox('Error', 'Please enter a valid email');
        return;
      }
      if (passwordController.text != confirmPasswordController.text) {
        Navigator.of(context).pop();
        dialogBox('Error', 'Passwords do not match');
        return;
      }
    } else {
      Navigator.of(context).pop();
      dialogBox('Error', 'Please fill in all the fields');
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameController.text);

        await FirebaseFirestore.instance
            .collection('user_roles')
            .doc(user.uid)
            .set({'role': role});
      }
      Navigator.of(context).pop();
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      dialogBox(e.code, e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyBuddy'),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.black,
                ),
                const Text(
                  'REGISTER',
                  style: TextStyle(fontSize: 50, color: Colors.black),
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 142, 139, 139)),
                  ),
                  controller: nameController,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 142, 139, 139)),
                  ),
                  controller: emailController,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 142, 139, 139)),
                  ),
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 142, 139, 139)),
                  ),
                  controller: confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(
                      value: 'student',
                      child: Text('I am a student'),
                    ),
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text('I am a teacher'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        setState(() {
                          role = newValue;
                        });
                      }
                    });
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                  onPressed: () {
                    register();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
