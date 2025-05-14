import 'package:dine_now/providers/auth_provider.dart';
// Import AuthService directly for signup
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController(); // Added for user's name
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // Added for confirmation
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = 'customer'; // Default role

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = ref.read(authServiceProvider);
        // Pass name along with email and password
        await authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(), // Pass the name
          _selectedRole, // Pass the selected role
        );
        // Signup successful, AuthWrapper will handle navigation
        if (mounted) {
          // Optionally pop the signup screen if successful,
          // AuthWrapper will show the main app anyway.
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'weak-password':
            message = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            message = 'An account already exists for that email.';
            break;
          case 'invalid-email':
            message = 'The email address is not valid.';
            break;
          default:
            message = 'An error occurred during sign up. Please try again.';
        }
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Use ListView to prevent overflow on smaller screens
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Select Role:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RadioListTile<String>(
                title: const Text('Customer'),
                value: 'customer',
                groupValue: _selectedRole,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
              RadioListTile<String>(
                title: const Text('Restaurant Owner'),
                value: 'owner',
                groupValue: _selectedRole,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
              RadioListTile<String>(
                title: const Text('Chef'),
                value: 'chef',
                groupValue: _selectedRole,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
              RadioListTile<String>(
                title: const Text('Staff'), // Added Staff role as per PRD
                value: 'staff',
                groupValue: _selectedRole,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ) // Center the indicator
              else
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Sign Up'),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          // Navigate back to Login Screen
                          Navigator.of(context).pop();
                        },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
