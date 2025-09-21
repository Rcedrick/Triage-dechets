import '../../services/map_service.dart';

class CollectionPoint {
  final String id;
  final String adresse;
  final String codePostal;
  final String commune;
  final double latitude;
  final double longitude;
  final List<String> types;
  final String nom;
  final String icone;
  final String description;

  CollectionPoint({
    required this.id,
    required this.adresse,
    required this.codePostal,
    required this.commune,
    required this.latitude,
    required this.longitude,
    required this.types,
    required this.nom,
    required this.icone,
    required this.description,
  });

  /// Factory pour Trilib (Paris)
  factory CollectionPoint.fromTrilibJson(Map<String, dynamic> json) {
    final f = json['fields'];
    final List<String> detectedTypes = [];

    final mmEmb = (f['nombre_de_module_mm_emb'] as num?)?.toInt() ?? 0;
    final verre = (f['nombre_de_module_verre'] as num?)?.toInt() ?? 0;

    if (mmEmb > 0) detectedTypes.addAll(["plastic", "metal", "paper-or-cardboard"]);
    if (verre > 0) detectedTypes.add("glass");
    if (detectedTypes.isEmpty) detectedTypes.add("non_recyclable");

    return CollectionPoint(
      id: f['identifiant'] as String,
      adresse: f['adresse'] ?? "Adresse non disponible",
      codePostal: f['code_postal']?.toString() ?? "",
      commune: f['commune'] ?? "",
      latitude: (f['latitude'] as num).toDouble(),
      longitude: (f['longitude'] as num).toDouble(),
      types: detectedTypes,
      nom: "Trilib'",
      icone: "assets/icons/trilib.png",
      description: "Point de collecte Trilib (multi-déchets), accessible 24/24h",
    );
  }

  /// Factory pour Colonnes à verre
  factory CollectionPoint.fromColonneVerreJson(Map<String, dynamic> json) {
    final f = json['fields'];
    final geo = f['geo_point_2d'] as List<dynamic>;
    final commune = f['commune'] ?? "";

    return CollectionPoint(
      id: json['recordid'] as String,
      adresse: f['adr'] ?? "Adresse non disponible",
      codePostal: f['arrdt']?.toString() ?? "",
      commune: commune,
      latitude: (geo[0] as num).toDouble(),
      longitude: (geo[1] as num).toDouble(),
      types: ["glass"],
      nom: "Colonne à verre",
      icone: "assets/icons/verre.png",
      description: "Point de collecte réservé au verre (bouteilles, bocaux, pots)",
    );
  }

  /// Factory pour Angers Loire Métropole
  factory CollectionPoint.fromAngersJson(Map<String, dynamic> f) {
    final geo = f['point_geo_pav'];
    final List<String> detectedTypes = [];

    if (f['verre'] != null) detectedTypes.add("glass");
    if (f['tri'] != null) detectedTypes.addAll(["plastic", "metal", "paper-or-cardboard"]);
    if (f['ordures_menageres'] != null) detectedTypes.add("non-recyclable");

    return CollectionPoint(
      id: "${f['adresse']}_${f['nom_commune']}",
      adresse: f['adresse'] ?? "Adresse non disponible",
      codePostal: f['code_postal']?.toString() ?? "",
      commune: f['nom_commune'] ?? "",
      latitude: (geo['lat'] as num).toDouble(),
      longitude: (geo['lon'] as num).toDouble(),
      types: detectedTypes.isNotEmpty ? detectedTypes : ["non-recyclable"],
      nom: "PAV Angers",
      icone: "assets/icons/angers.png",
      description: "Point d’apport volontaire - Angers Loire Métropole",
    );
  }


  /// Factory pour Seine Ouest
  factory CollectionPoint.fromSeineOuestJson(Map<String, dynamic> json) {
    final localisation = json['localisation'] ?? "";
    final numLoc = json['num_loc'] ?? "";
    final repLoc = json['rep_loc'] ?? "";
    final adresseComplete = "$numLoc${repLoc != null ? repLoc : ''} $localisation";

    final geo = json['geo_point_2d'];
    final contenu = (json['contenu'] ?? "").toString().toLowerCase();

    final List<String> detectedTypes = [];
    if (contenu.contains("sélective")) detectedTypes.addAll(["plastic", "metal", "paper-or-cardboard"]);
    if (contenu.contains("ordures")) detectedTypes.add("non-recyclable");

    return CollectionPoint(
      id: json['code_insee'] ?? "",
      adresse: adresseComplete.trim().isNotEmpty ? adresseComplete : "Adresse non disponible",
      codePostal: "",
      commune: json['commune'],
      latitude: (geo['lat'] as num).toDouble(),
      longitude: (geo['lon'] as num).toDouble(),
      types: detectedTypes.isNotEmpty ? detectedTypes : ["non-recyclable"],
      nom: "PAV Seine Ouest",
      icone: "assets/icons/seineouest.png",
      description: "Point d’apport volontaire - Seine Ouest",
    );
  }

  /// Factory pour Nantes (Ecopoints)
  factory CollectionPoint.fromNantesJson(Map<String, dynamic> f) {
    final geo = f['geo_point_2d'];

    final List<String> detectedTypes = [];

    if (f['verre'] == "oui") detectedTypes.add("glass");
    if (f['carton'] == "oui" || f['papier'] == "oui") detectedTypes.add("paper-or-cardboard");
    if (f['metal'] == "oui" || f['ferraille'] == "oui") detectedTypes.add("metal");
    if (f['plastic'] == "oui" || f['polystyrene'] == "oui") detectedTypes.add("plastic");
    if (detectedTypes.isEmpty) detectedTypes.add("non-recyclable");

    return CollectionPoint(
      id: f['identifiant'].toString(),
      adresse: f['adresse'] ?? "Adresse non disponible",
      codePostal: f['code_postal']?.toString() ?? "",
      commune: f['commune'] ?? "",
      latitude: (geo['lat'] as num).toDouble(),
      longitude: (geo['lon'] as num).toDouble(),
      types: detectedTypes,
      nom: f['nom'] ?? "Ecopoint",
      icone: "assets/icons/nantes.png",
      description: "Ecopoint de Nantes Métropole",
    );
  }

  /// Factory pour colonnes aériennes Nantes
  factory CollectionPoint.fromColonneNantesJson(Map<String, dynamic> f) {
    final geo = f['geo_point_2d'];

    final List<String> detectedTypes = [];

    final typeDechet = (f['type_dechet'] ?? "").toString().toLowerCase();
    final matiere = (f['matiere'] ?? "").toString().toLowerCase();

    if ( matiere.contains("plastique")) detectedTypes.add("plastic");
    if (typeDechet.contains("déchet recyclable")) detectedTypes.addAll(["plastic", "metal", "paper-or-cardboard"]);
    if (typeDechet.contains("papier-carton")) detectedTypes.add("paper-or-cardboard");
    if (typeDechet.contains("verre")) detectedTypes.add("glass");
    if (typeDechet.contains("ordure ménagère")) detectedTypes.add("non-recyclable");
    if (detectedTypes.isEmpty) detectedTypes.add("non-recyclable");

    return CollectionPoint(
      id: f['gid']?.toString() ?? f['id_colonne_ancien'] ?? "unknown",
      adresse: f['adresse'] ?? "Adresse non disponible",
      codePostal: "",
      commune: f['commune'] ?? "",
      latitude: (geo['lat'] as num).toDouble(),
      longitude: (geo['lon'] as num).toDouble(),
      types: detectedTypes,
      nom: "Colonne aérienne Nantes",
      icone: "assets/icons/nantes.png",
      description: "Colonne aérienne pour déchets recyclables",
    );
  }

  /// Factory pour Rennes Métropole (Points d'apport volontaire)
  factory CollectionPoint.fromRennesJson(Map<String, dynamic> f, String commune) {
    final geo = f['geo_point_2d'];

    final List<String> detectedTypes = [];

    if ((f['flux_om'] ?? 0) > 0) detectedTypes.add("non-recyclable");
    if ((f['flux_mm'] ?? 0) > 0) {
      detectedTypes.addAll(["plastic", "metal", "paper-or-cardboard"]);
    }
    if ((f['flux_jm'] ?? 0) > 0) detectedTypes.add("paper-or-cardboard");
    if ((f['flux_ca'] ?? 0) > 0) detectedTypes.add("paper-or-cardboard");
    if ((f['flux_ve'] ?? 0) > 0) detectedTypes.add("glass");

    if (detectedTypes.isEmpty) {
      detectedTypes.add("non-recyclable");
    }

    final adresse = f['adresse_complete'] ?? "Adresse non disponible";
    final communeExtracted = adresse.contains(",")
        ? adresse.split(",").last.trim()
        : commune;
    return CollectionPoint(
      id: f['gml_id'] ?? "",
      adresse: adresse,
      codePostal: "",
      commune: communeExtracted,
      latitude: (geo['lat'] as num).toDouble(),
      longitude: (geo['lon'] as num).toDouble(),
      types: detectedTypes,
      nom: "PAV ${communeExtracted}",
      icone: "assets/icons/rennes.png",
      description: "Point d’apport volontaire - ${communeExtracted}",
    );
  }

  factory CollectionPoint.fromRennes2Json(Map<String, dynamic> f, String commune) {
    final geo = f['geo_point_2d'];

    final List<String> detectedTypes = [];

    if ((f['flux_om'] ?? 0) > 0) detectedTypes.add("non-recyclable");
    if ((f['flux_mm'] ?? 0) > 0) {
      detectedTypes.addAll(["plastic", "metal", "paper-or-cardboard"]);
    }
    if ((f['flux_jm'] ?? 0) > 0) detectedTypes.add("paper-or-cardboard");
    if ((f['flux_ca'] ?? 0) > 0) detectedTypes.add("paper-or-cardboard");
    if ((f['flux_ve'] ?? 0) > 0) detectedTypes.add("glass");

    if (detectedTypes.isEmpty) {
      detectedTypes.add("non-recyclable");
    }

    final adresse = f['adresse_complete'] ?? "Adresse non disponible";
    final communeExtracted = adresse.contains(",")
        ? adresse.split(",").last.trim()
        : commune;
    return CollectionPoint(
      id: f['gml_id'] ?? "",
      adresse: adresse,
      codePostal: "",
      commune: communeExtracted,
      latitude: (geo['lat'] as num).toDouble(),
      longitude: (geo['lon'] as num).toDouble(),
      types: detectedTypes,
      nom: "PAV ${communeExtracted}",
      icone: "assets/icons/rennes2.png",
      description: "Point d’apport volontaire - ${communeExtracted}",
    );
  }

}
