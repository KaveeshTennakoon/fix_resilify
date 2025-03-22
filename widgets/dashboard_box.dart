import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';


// onTap will be used to redirect to other pages

class DashboardBox extends StatelessWidget {
  final String imagePath;
  final String label;
  //final VoidCallback onTap;

  const DashboardBox({
    super.key,
    required this.imagePath,
    required this.label, required String subtitle,
    //required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}