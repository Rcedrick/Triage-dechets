import 'package:flutter/material.dart';
import '../utils/theme_util.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
          strokeWidth: 5,
        ),
      ),
    );
  }
}
