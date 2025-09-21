import 'package:flutter/material.dart';
import '../utils/theme_util.dart';

Widget buildEcoBadge(String text, double textSize, double iconSize) {
  return Row(
    children: [
      Text(
        text,
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        width: iconSize + 12,
        height: iconSize + 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.eco,
            color: primaryColor,
            size: iconSize,
          ),
        ),
      ),
    ],
  );
}
