import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';

class CustomLargeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomLargeTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 6,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.primaryTextColor),
        filled: true,
        fillColor: AppColors.fourthColor,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
      style: TextStyle(fontSize: 16, color: AppColors.secondaryTextColor),
    );
  }
}
