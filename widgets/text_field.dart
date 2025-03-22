import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final bool hasAsteriks;
  final int maxLines;
  final bool enabled; // Added enabled parameter

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.hasAsteriks = false,
    this.maxLines = 1,
    this.enabled = true, // Default value is true
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      controller: widget.controller,
      obscureText: widget.hasAsteriks ? !_isPasswordVisible : false,
      maxLines: widget.maxLines,
      enabled: widget.enabled, // Use the enabled parameter
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: widget.enabled
              ? AppColors.primaryColor
              : AppColors.primaryColor.withOpacity(0.5), // Dimmer hint for disabled state
        ),
        filled: true,
        fillColor: widget.enabled
            ? AppColors.fourthColor
            : AppColors.fourthColor.withOpacity(0.7), // Slightly dimmer background for disabled state
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.hasAsteriks && widget.enabled // Only show toggle button if field is enabled
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        )
            : null,
      ),
      style: TextStyle(
        color: widget.enabled
            ? Colors.black
            : Colors.black54, // Dimmer text for disabled state
      ),
    );
  }
}