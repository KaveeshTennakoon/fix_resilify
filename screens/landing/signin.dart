import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/widgets/custom_button.dart';
import 'package:resilify/widgets/custom_label.dart';
import 'package:resilify/widgets/text_field.dart';
import 'package:provider/provider.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  // Firebase Email/Password Sign In
  Future<void> signin(BuildContext context) async {
    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final userCredential = await authService.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          context: context,
        );

        if (userCredential != null) {
          if (!mounted) return;
          // Navigate to home on successful login
          Navigator.pushNamedAndRemoveUntil(
            context, '/home', (Route<dynamic> route) => false,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      debugPrint("Login validation failed");
    }
  }

  // Navigate to Signup
  void _signup(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  // Reset Password
  void _resetPassword(BuildContext context) {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address first")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Text("Send password reset email to ${emailController.text}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              authService.resetPassword(emailController.text.trim(), context);
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
        children: [
          // Above section and image
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Image.asset('assets/img/logo_2.png'),
            ),
          ),

          // Expanded section for scrolling content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white, // Makes bottom part white
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SafeArea( // Avoids overlapping with system UI
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Textfields
                        Form(
                          key: _formkey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomLabel(text: "Email"),
                              CustomTextField(
                                hintText: "Enter email",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email";
                                  } else if (!RegExp(
                                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                      .hasMatch(value)) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                                controller: emailController,
                              ),
                              const SizedBox(height: 15),
                              const CustomLabel(text: "Password"),
                              CustomTextField(
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  return null;
                                },
                                hintText: "Enter password",
                                hasAsteriks: true,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _resetPassword(context),
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(fontWeight: FontWeight.w100),
                              ),
                            ),
                          ],
                        ),
                        CustomButton(
                            text: "Sign in",
                            onPress: () => signin(context)),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Do not have an account?",
                              style: TextStyle(color: AppColors.primaryTextColor),
                            ),
                            TextButton(
                              onPressed: () => _signup(context),
                              child: Text(
                                "SIGN UP",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryTextColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}