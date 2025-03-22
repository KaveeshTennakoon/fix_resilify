import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/widgets/custom_button.dart';
import 'package:resilify/widgets/custom_label.dart';
import 'package:resilify/widgets/text_field.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formkey = GlobalKey<FormState>();

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Firebase Email/Password Signup Method
  Future<void> signup(BuildContext context) async {
    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final userCredential = await authService.signUpWithEmailAndPassword(
          email: emailNameController.text.trim(),
          password: passwordController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          context: context,
        );

        if (userCredential != null) {
          if (!mounted) return;
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
      debugPrint("Signup validation failed.");
    }
  }

  // Navigate to Sign In
  void _signin(BuildContext context) {
    Navigator.pushNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(children: [
          // 🔹 Logo
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Image.asset('assets/img/logo_2.png'),
            ),
          ),

          // 🔹 Signup Form
          Expanded(
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.only(left: 30, top: 0, right: 30),
                      child: ListView(children: [
                        Text(
                          "Sign up",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColor),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Form Fields
                        Form(
                            key: _formkey,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomLabel(text: "First Name"),
                                  CustomTextField(
                                    controller: firstNameController,
                                    validator: (value) => value!.isEmpty ? "Please enter your first name" : null,
                                    hintText: "Enter first name",
                                  ),
                                  const SizedBox(height: 15),

                                  const CustomLabel(text: "Last Name"),
                                  CustomTextField(
                                    controller: lastNameController,
                                    validator: (value) => value!.isEmpty ? "Please enter your last name" : null,
                                    hintText: "Enter last name",
                                  ),
                                  const SizedBox(height: 15),

                                  const CustomLabel(text: "Email"),
                                  CustomTextField(
                                    hintText: "Enter email",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return "Please enter your email";
                                      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                                        return "Please enter a valid email";
                                      }
                                      return null;
                                    },
                                    controller: emailNameController,
                                  ),
                                  const SizedBox(height: 15),

                                  const CustomLabel(text: "Password"),
                                  CustomTextField(
                                    controller: passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return "Please enter your password";
                                      if (value.length < 6) return "Password must be at least 6 characters";
                                      return null;
                                    },
                                    hintText: "Enter password",
                                    hasAsteriks: true,
                                  ),
                                  const SizedBox(height: 15),

                                  const CustomLabel(text: "Confirm Password"),
                                  CustomTextField(
                                    controller: confirmPasswordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return "Please re-enter your password";
                                      if (value != passwordController.text) return "Passwords do not match";
                                      return null;
                                    },
                                    hintText: "Re-enter password",
                                    hasAsteriks: true,
                                  ),
                                ])),

                        const SizedBox(height: 30),

                        // 🔹 Sign Up Button
                        CustomButton(text: "Sign Up", onPress: () => signup(context)),

                        const SizedBox(height: 30),

                        // 🔹 Already have an account? Sign In
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?", style: TextStyle(color: AppColors.primaryTextColor)),
                            TextButton(
                              onPressed: () => _signin(context),
                              child: Text("SIGN IN", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryTextColor)),
                            ),
                          ],
                        ),
                      ]))))
        ]));
  }
}