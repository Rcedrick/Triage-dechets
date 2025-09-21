import 'package:flutter/material.dart';

Color getMaterialColor(String? type) {
  switch (type) {
    case "plastic":
      return Colors.blue;
    case "metal":
      return Colors.grey;
    case "paper-or-cardboard":
      return Colors.yellow;
    case "glass":
      return Colors.green;
    case "non-recyclable":
      return Colors.brown;
    default:
      return Colors.black;
  }
}
