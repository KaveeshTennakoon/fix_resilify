import 'package:flutter/material.dart';

class CognitiveMascotPage extends StatelessWidget {
  final String reframedThought;
  const CognitiveMascotPage({super.key, required this.reframedThought});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mascot Page")),
      body: Center(child: Text("Mascot looping: $reframedThought")),
    );
  }
}