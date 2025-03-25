import 'package:flutter/material.dart';
import 'package:hotel_management/services/chef_auth.dart';

class Chefsignup extends StatefulWidget {
  const Chefsignup({super.key});

  @override
  State<Chefsignup> createState() => _ChefsignupState();
}

class _ChefsignupState extends State<Chefsignup> {
final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Perform registration validation
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Passwords do not match')),
      );
      return;
    }

    // Create an instance of AuthService
    AuthService authService = AuthService(
      emailText: email,
      passwordText: password,
      confirmPasswordText: confirmPassword,
      usernameText: username,
    );

    // Call the registerUser method
    authService.registerUser(context);

    // Clear the text fields after registration attempt
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Sign Up"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Register Account",
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                "Complete your details or continue \nwith social media",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF757575)),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: "Enter username",
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Re-enter your password",
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Continue Button
              ElevatedButton(
                onPressed: () {
                  _register();
                },
                child: const Text('Continue'),
              ),
              const SizedBox(height: 32),
              // Social Media Icons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialCard(Icons.email, () {}),
                  const SizedBox(width: 16),
                  _buildSocialCard(Icons.facebook, () {}),
                  const SizedBox(width: 16),
                  _buildSocialCard(Icons.phone, () {}),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "By continuing your confirm that you agree \nwith our Term and Condition",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build Social Cards
  Widget _buildSocialCard(IconData icon, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(icon),
      ),
    );
  }
}
