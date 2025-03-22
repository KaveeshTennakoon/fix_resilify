import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';

Future<bool> showExitConfirmationDialog(
    BuildContext context, String exitRoute, Function(bool) onExit) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Confirm Exit",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextColor,
        ),
      ),
      content: const Text("Are you sure you want to exit?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);  // Close the dialog and pass false
            onExit(false); // Notify the game page that the user canceled
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);   // Close the dialog and pass true
            onExit(true); // Notify the game page that the user confirmed
          },
          child: const Text("Yes"),
        ),
      ],
    ),
  ) ??
      false;  // Default return value in case the dialog is dismissed without selection
}