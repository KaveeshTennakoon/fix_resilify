import 'package:flutter/material.dart';
import 'package:resilify/widgets/dashboard_box.dart';


class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.21, -0.98),
          end: Alignment(-0.21, 0.98),
          colors: [Colors.white, Color(0xFFD4B8F2)],
        ),
      ),
      child: SingleChildScrollView(  // Add this to make the content scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),  // Add some padding at the top

              // Banner section
              Container(
                width: double.infinity,
                height: 141,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(-1.00, 0.00),
                    end: Alignment(1, 0),
                    colors: [Color(0xFFBC90E2), Colors.white],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      left: 27,
                      top: 14,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.85, -0.53),
                            end: Alignment(-0.85, 0.53),
                            colors: [Colors.white, Color(0xFF491EA3)],
                          ),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 292,
                      top: 20,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.85, -0.53),
                            end: Alignment(-0.85, 0.53),
                            colors: [Colors.white, Color(0xA54A1EA3)],
                          ),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 214,
                      top: 106,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.85, -0.53),
                            end: Alignment(-0.85, 0.53),
                            colors: [Colors.white, Color(0xA54A1EA3)],
                          ),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 329,
                      top: 80,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.85, -0.53),
                            end: Alignment(-0.85, 0.53),
                            colors: [Colors.white, Color(0xA54A1EA3)],
                          ),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    // Banner text
                    Positioned(
                      left: 30,
                      top: 50,
                      child: SizedBox(
                        width: 293,
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Train Your Thoughts, \n',
                                style: TextStyle(
                                  color: Color(0xA54A1EA3),
                                  fontSize: 20,
                                  fontFamily: 'Archivo',
                                  fontWeight: FontWeight.w700,
                                  height: 1.50,
                                ),
                              ),
                              TextSpan(
                                text: 'Transform Your Life!',
                                style: TextStyle(
                                  color: Color(0xA54A1EA3),
                                  fontSize: 20,
                                  fontFamily: 'Archivo',
                                  fontWeight: FontWeight.w300,
                                  height: 1.50,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Tools section header
              const Text(
                'Explore Your Tools',
                style: TextStyle(
                  color: Color(0xA54A1EA3),
                  fontSize: 16,
                  fontFamily: 'Archivo',
                  fontWeight: FontWeight.w700,
                  height: 1.88,
                ),
              ),

              const SizedBox(height: 15),

              // Dashboard boxes section
              Column(
                children: [
                  // First row of boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/cognitive_input');
                        },
                        child: const DashboardBox(
                          imagePath: "assets/img/Cognitive_reframing.png",
                          label: "Positive Reframing",
                          subtitle: "Shift your mindset",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/erp_loop');
                        },
                        child: const DashboardBox(
                          imagePath: "assets/img/dashboard2.png",
                          label: "Loop-Taping",
                          subtitle: "Neutralize thoughts",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  // Second row of boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/ThriveAndGrow');
                        },
                        child: const DashboardBox(
                          imagePath: "assets/img/dashboard3.png",
                          label: "Thrive & Grow",
                          subtitle: "Nurture your mind",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/breathing_exercise');
                        },
                        child: const DashboardBox(
                          imagePath: "assets/img/dashboard4.png",
                          label: "Exercises",
                          subtitle: "Calm your mind",
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Progress button
              Center(
                child: Container(
                  width: 319,
                  height: 47,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(1.00, 0.00),
                      end: Alignment(-1, 0),
                      colors: [Color(0xFFAA68E4), Color(0xFFF8F8F8)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(width: 10),
                        Text(
                          'Track Your Progress',
                          style: TextStyle(
                            color: Color(0xFFFFF9F9),
                            fontSize: 16,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.08,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}