import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';

class CustomLabel extends StatelessWidget {
  final String text;
  const CustomLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor),
      ),
    );
  }
}