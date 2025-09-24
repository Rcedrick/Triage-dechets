// utils/material_categories.dart

import 'dart:ui';

import 'package:flutter/material.dart';

class MaterialCategory {
  final String id;
  final String name;
  final Color color;
  final List<String> keywords;

  const MaterialCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.keywords,
  });
}

class MaterialCategories {
  static final List<MaterialCategory> all = [
    plastic,
    metal,
    paperCardboard,
    glass,
    nonRecyclable,
  ];

  static const plastic = MaterialCategory(
    id: "plastic",
    name: "Plastique",
    color: Colors.blue,
    keywords: [
      "pp", "pet", "pehd", "peld", "polypropylene", "polyethylene", "polystyrene",
      "plastic", "plastique", "poly", "hdpe", "ldpe", "ps", "pla", "bouteille plastique", "film plastique"
    ],
  );

  static const metal = MaterialCategory(
    id: "metal",
    name: "Métal",
    color: Colors.grey,
    keywords: [
      "aluminium", "alu", "steel", "acier", "metal", "fer", "canette", "tin", "lid", "Polypropylene",
      "boîte de conserve", "capsule", "feuille d'aluminium"
    ],
  );

  static const paperCardboard = MaterialCategory(
    id: "paper-or-cardboard",
    name: "Papier/Carton",
    color: Colors.yellow,
    keywords: [
      "paper", "papier", "cardboard", "carton", "journal", "magazine",
      "papier kraft", "boîte en carton", "livre", "enveloppe"
    ],
  );

  static const glass = MaterialCategory(
    id: "glass",
    name: "Verre",
    color: Colors.green,
    keywords: [
      "glass", "verre", "bouteille en verre", "bocal", "pot", "flacon",
      "miroir", "vitre"
    ],
  );

  static const nonRecyclable = MaterialCategory(
    id: "non-recyclable",
    name: "Non recyclable",
    color: Colors.brown,
    keywords: [
      "non_recyclable", "non_biodegradable", "ordures", "restes alimentaires",
      "poubelle grise", "plastique souple", "polystyrène expansé", "mégot", "céramique", "tissu"
    ],
  );

  static MaterialCategory getById(String id) {
    return all.firstWhere(
          (category) => category.id == id,
      orElse: () => MaterialCategory(
        id: "other",
        name: "Autre",
        color: Colors.black,
        keywords: [],
      ),
    );
  }

  static String getCategoryName(String id) {
    return getById(id).name;
  }

  static Color getCategoryColor(String id) {
    return getById(id).color;
  }
}