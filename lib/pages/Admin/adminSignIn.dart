import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_management/components/button.dart';
import 'package:hotel_management/components/my_textfield.dart';
import 'package:hotel_management/components/square_tile.dart';
import 'package:hotel_management/themes/colors.dart';

class AdminSignIn extends StatelessWidget {
  AdminSignIn({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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
                      Icons.admin_panel_settings,
                      color: primaryColor,
                      size: screenWidth * 0.2, // Responsive icon size
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // welcome back, you've been missed!
                    Text(
                      'Analyze, Manage, and Grow!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // username textfield
                    MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // password textfield
                    MyTextField(
                      controller: passwordController,
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
                        Navigator.pushNamed(context, '/adminhomepage'),
                      },
                      text: 'Sign In',
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
                            Navigator.pushNamed(context, '/signuppage');
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
