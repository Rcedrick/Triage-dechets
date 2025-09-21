import 'package:flutter/material.dart';
import 'package:tri_dechets/utils/theme_util.dart';

void showLoading(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(color: backgroundColor),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}


void hideLoading(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

Widget buildLoadingScreen() {
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