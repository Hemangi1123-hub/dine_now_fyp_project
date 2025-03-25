import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_management/components/my_button.dart';
import 'package:hotel_management/components/my_textfield.dart';
import 'package:hotel_management/components/square_tile.dart';
import 'package:hotel_management/services/chef_auth.dart';
import 'package:hotel_management/themes/colors.dart';

class Chefssignin extends StatefulWidget {
  Chefssignin({super.key});

  @override
  State<Chefssignin> createState() => _ChefssigninState();
}

class _ChefssigninState extends State<Chefssignin> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  // sign user in method
  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Validate email and password
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Perform login
    AuthService authService = AuthService(
      emailText: email,
      passwordText: password,
    );

    try {
      authService.loginUser(context);
      Navigator.pushNamed(context, '/requestnavigator');
      // Navigate to home screen after successful login
    } catch (e) {
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      screenWidth * 0.1, // Responsive horizontal padding
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // logo
                    Icon(
                      Icons.cookie,
                      color: primaryColor,
                      size: screenWidth * 0.2, // Responsive icon size
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // welcome back, you've been missed!
                    Text(
                      'Chef, you the best!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // username textfield
                    MyTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // password textfield
                    MyTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // forgot password?
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // sign in button
                    MyButton(
                      onTap: () => {
                        _login(),
                      },
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // or continue with
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // google + apple sign in buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // google button
                        SquareTile(imagePath: 'lib/images/google.png'),

                        SizedBox(width: screenWidth * 0.05),

                        // apple button
                        SquareTile(imagePath: 'lib/images/apple.png')
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a member?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/chefsignup');
                          },
                          child: Text(
                            'Register now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
