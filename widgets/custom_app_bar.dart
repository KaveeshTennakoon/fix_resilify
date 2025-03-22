import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.secondaryColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryTextColor),
              SizedBox(width: 8),
              Text("Hello User!", style: TextStyle(color: AppColors.primaryTextColor)),
            ],
          ),
          Row(
            children: [
              Text("15", style: TextStyle(color: AppColors.primaryTextColor)),
              SizedBox(width: 4),
              Icon(Icons.local_fire_department, color: Colors.green),
              SizedBox(width: 10),
              Text("280", style: TextStyle(color: AppColors.primaryTextColor)),
              SizedBox(width: 4),
              Icon(Icons.monetization_on, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60); //  Required fix for app bar
}