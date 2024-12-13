import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class ProfileTab extends StatefulWidget {
  ProfileTab({super.key});
  
  User? user = FirebaseAuth.instance.currentUser;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user?.displayName ?? '';
  }

  // Display dialog
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

  // Method to update the display name
  void _changeName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Name'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            controller: _nameController,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (_nameController.text.isEmpty) {
                  dialogBox('Error', 'Name cannot be empty');
                  return;
                }
                try {
                  // Update the display name
                  await widget.user?.updateDisplayName(_nameController.text);

                  // Reload user to reflect changes
                  await widget.user?.reload();

                  // Refresh the current user data
                  User? updatedUser = FirebaseAuth.instance.currentUser;

                  // Update the name controller with the new name
                  setState(() {
                    widget.user = updatedUser;
                    _nameController.text = updatedUser?.displayName ?? '';
                  });

                  _nameController.clear();
                  dialogBox('Success', 'Name updated successfully');
                } on FirebaseAuthException catch (e) {
                  dialogBox(e.code, e.message.toString());
                }
              },
              child: Text('Change Name'),
            ),
          ],
        );
      },
    );
  }

  // Method to log out the user
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Method to change password
  void _changePass() async {
    Navigator.of(context).pop();
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      dialogBox('Error', 'Passwords do not match');
      _formKey.currentState!.reset();
      return;
    }
    try {
      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: widget.user!.email!,
          password: _currentPasswordController.text,
        ),
      );
    } on FirebaseAuthException catch (e) {
      dialogBox(e.code, e.message.toString());
      _formKey.currentState!.reset();
    }

    try {
      await FirebaseAuth.instance.currentUser!
          .updatePassword(_newPasswordController.text);
      dialogBox('Success', 'Password updated successfully');
      _formKey.currentState!.reset();
    } on FirebaseAuthException catch (e) {
      dialogBox(e.code, e.message.toString());
      _formKey.currentState!.reset();
    }
  }

  // Method to change password via dialog
  void _changePassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  obscureText: true,
                  controller: _currentPasswordController,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                  obscureText: true,
                  controller: _newPasswordController,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  obscureText: true,
                  controller: _confirmNewPasswordController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                _changePass();
              },
              child: Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _logout();
              })
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(widget.user?.displayName ?? 'No Name'),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _changeName();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.user?.email ?? 'No Email'),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Account ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.user!.uid));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied to clipboard'),
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.user!.uid,
                      style: DefaultTextStyle.of(context).style,
                    ),
                    const WidgetSpan(
                      child: SizedBox(width: 5),
                    ),
                    WidgetSpan(
                      child: Icon(Icons.copy, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Account Creation Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.user!.metadata.creationTime.toString()),
            const SizedBox(height: 16.0),
            const Text(
              'Last Sign In Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.user!.metadata.lastSignInTime.toString()),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            const Text(
              'Security',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Update Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                _changePassword();
              },
              child: const Row(
                children: [
                  Icon(Icons.lock),
                  SizedBox(width: 5),
                  Text('Change Password'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
