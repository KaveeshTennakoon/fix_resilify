import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPress;

  // Default colors for background and foreground
  static const Color _defaultBackgroundColor = Color(0xFFD4B8F2); // Light gray
  static const Color _defaultForegroundColor = Colors.white; // Black text

  const CustomButton({
    super.key,
    required this.text,
    this.backgroundColor = _defaultBackgroundColor, // Default value
    this.foregroundColor = _defaultForegroundColor, // Default value
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}