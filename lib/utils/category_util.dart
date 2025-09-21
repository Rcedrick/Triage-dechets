final List<String> plasticKeywords = [
  "pp", "pet", "pehd", "peld", "polypropylene", "polyethylene", "polystyrene",
  "plastic", "plastique", "poly", "hdpe", "ldpe", "ps", "pla", "bouteille plastique", "film plastique"
];

final List<String> metalKeywords = [
  "aluminium", "alu", "steel", "acier", "metal", "fer", "canette", "tin","lid","Polypropylene",
  "boîte de conserve", "capsule", "feuille d’aluminium"
];

final List<String> paperCardboardKeywords = [
  "paper", "papier", "cardboard", "carton", "journal", "magazine",
  "papier kraft", "boîte en carton", "livre", "enveloppe"
];

final List<String> glassKeywords = [
  "glass", "verre", "bouteille en verre", "bocal", "pot", "flacon",
  "miroir", "vitre"
];

final List<String> nonRecyclableKeywords = [
  "non_recyclable", "non_biodegradable", "ordures", "restes alimentaires",
  "poubelle grise", "plastique souple", "polystyrène expansé", "mégot", "céramique", "tissu"
];


String categorizeMaterial(String? rawMaterial, String? recycling) {

  if (rawMaterial == null) return "other";
  final mat = rawMaterial.toLowerCase();

  if (recycling != null && recycling.toLowerCase().contains("discard")) {
    return "non-recyclable";
  }

  if (plasticKeywords.any((k) => mat.contains(k))) {
    return "plastic";
  }
  if (metalKeywords.any((k) => mat.contains(k))) {
    return "metal";
  }
  if (paperCardboardKeywords.any((k) => mat.contains(k))) {
    return "paper-or-cardboard";
  }
  if (glassKeywords.any((k) => mat.contains(k))) {
    return "glass";
  }
  if (nonRecyclableKeywords.any((k) => mat.contains(k))) {
    return "non-recyclable";
  }

  return "other";
}
