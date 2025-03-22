import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:resilify/services/auth_service.dart';

import 'package:resilify/core/app_colors.dart';
import 'package:resilify/widgets/custom_button.dart';
import 'package:resilify/widgets/custom_label.dart';
import 'package:resilify/widgets/text_field.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _showRemoveButton = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from AuthService
  void _loadUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.getCurrentUserDTO();

    if (user != null) {
      setState(() {
        firstNameController.text = user.firstName;
        lastNameController.text = user.lastName;
        emailController.text = user.email;
      });
    }
  }

  // Handle logout
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      if (!mounted) return;

      // Navigate to the landing or login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/landing',
              (route) => false
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e"))
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _showRemoveButton = false;
    });
  }

  // Save profile
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Update profile
      await authService.updateUserProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        context: context,
      );

      // Handle password change if provided
      if (passwordController.text.isNotEmpty) {
        // Note: You'll need to implement password update in your AuthService
        // This is just a placeholder
        // await authService.updatePassword(passwordController.text);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully"))
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e"))
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
        : SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          children: [
            // Logout Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton.icon(
                onPressed: _showLogoutConfirmation,
                icon: Icon(
                  Icons.logout,
                  color: AppColors.tertiaryColor,
                  size: 24,
                ),
                label: Text(
                  "Logout",
                  style: TextStyle(
                    color: AppColors.tertiaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Profile Details Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture Section
                  GestureDetector(
                    onTap: () {
                      if (_image != null) {
                        setState(() {
                          _showRemoveButton = !_showRemoveButton;
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.fourthColor,
                          backgroundImage: _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(
                            Icons.person_outline,
                            size: 100,
                            color: AppColors.primaryColor,
                          )
                              : null,
                        ),
                        // Camera Button
                        Positioned(
                          bottom: 0,
                          right: -8,
                          child: IconButton(
                            onPressed: _pickImage,
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        // Remove Button (Visible when tapped and image exists)
                        if (_image != null && _showRemoveButton)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  //rest of the fields
                  const SizedBox(height: 20),
                  CustomLabel(text: "First Name"),
                  CustomTextField(
                    controller: firstNameController,
                    hintText: "First Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "First name cannot be empty";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomLabel(text: "Last Name"),
                  CustomTextField(
                    controller: lastNameController,
                    hintText: "Last Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Last name cannot be empty";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomLabel(text: "Age"),
                  CustomTextField(
                    controller: ageController,
                    hintText: "Age",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Age cannot be empty";
                      } else if (int.tryParse(value) == null) {
                        return "Enter a valid number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomLabel(text: "New Password"),
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Enter new password",
                    hasAsteriks: true,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  //save button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Save",
                      onPress: _saveProfile,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    ageController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}