import 'package:flutter/material.dart';
import '../utils/theme_util.dart';

Widget buildSearchBar({
  required String hintText,
  required Function(String) onChanged,
  double fontSize = 18,
  IconData icon = Icons.search,
  Color cursorColor = primaryColor,
  Color focusedBorderColor = primaryColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TextField(
      cursorColor: cursorColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
        ),
        suffixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: focusedBorderColor, width: 2), // couleur quand focus
        ),
      ),
      onChanged: onChanged,
    ),
  );
}

