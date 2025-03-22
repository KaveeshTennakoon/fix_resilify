import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/screens/dashboards/dashboard.dart';
import 'package:resilify/screens/landing/profile.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int myIndex = 0;
  List<Widget> screenList = [
    Dashboard(),
    Text("Screen"),
    Profile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: screenList[myIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
      ),
    );
  }
}          // Handle bottom navigation bar tap



