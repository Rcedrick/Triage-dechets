import 'dart:ui';

import 'package:flutter/material.dart';

import 'material_categories.dart';

String categorizeMaterial(String? rawMaterial, String? recycling) {
  if (rawMaterial == null) return "other";

  final mat = rawMaterial.toLowerCase();

  if (recycling != null && recycling.toLowerCase().contains("discard")) {
    return "non-recyclable";
  }

  for (final category in MaterialCategories.all) {
    if (category.keywords.any((keyword) => mat.contains(keyword))) {
      return category.id;
    }
  }

  return "other";
}

// Remplacer getMaterialColor par cette fonction
Color getMaterialColor(String? type) {
  if (type == null) return Colors.black;
  return MaterialCategories.getCategoryColor(type);
}

String getMaterialName(String? type) {
  if (type == null) return "Autre";
  return MaterialCategories.getCategoryName(type);
}