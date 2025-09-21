import 'dart:convert';
import 'package:http/http.dart' as http;
import '../API/map/pointCollecte.dart';

class MapService {
  static Future<List<CollectionPoint>> fetchStationsByPostal(String codePostal,String commune ) async {
    final List<CollectionPoint> points = [];

    // 1. Trilib API
    final urlTrilib =
        'https://opendata.paris.fr/api/records/1.0/search/'
        '?dataset=dechets-menagers-points-dapport-volontaire-stations-trilib'
        '&refine.code_postal=$codePostal'
        '&rows=100';

    final resTrilib = await http.get(Uri.parse(urlTrilib));
    if (resTrilib.statusCode == 200) {
      final data = jsonDecode(resTrilib.body);
      final recs = data['records'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromTrilibJson(r)));
    }

    // 2. Colonnes à verre API
    final urlVerre =
        'https://opendata.paris.fr/api/records/1.0/search/'
        '?dataset=dechets-menagers-points-dapport-volontaire-colonnes-a-verre'
        '&refine.arrdt=$codePostal'
        '&rows=100';

    final resVerre = await http.get(Uri.parse(urlVerre));
    if (resVerre.statusCode == 200) {
      final data = jsonDecode(resVerre.body);
      final recs = data['records'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromColonneVerreJson(r)));
    }

    // 3. Angers Loire Métropole API
    final urlAngers =
        'https://data.angers.fr/api/explore/v2.1/catalog/datasets/point-apport-volontaire-dechets/records'
        '?where=nom_commune="${commune.toUpperCase()}"&limit=100';

    final resAngers = await http.get(Uri.parse(urlAngers));
    if (resAngers.statusCode == 200) {
      final data = jsonDecode(resAngers.body);
      final recs = data['results'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromAngersJson(r)));
    }

    // 4. Seine Ouest (GPSO) API
    final urlSeineOuest =
        'https://data.seineouest.fr/api/explore/v2.1/catalog/datasets/point-de-collecte-enterree/records'
        '?where=commune%3D%22${commune.toUpperCase()}%22'
        '&limit=100';

    final resSeineOuest = await http.get(Uri.parse(urlSeineOuest));
    if (resSeineOuest.statusCode == 200) {
      final data = jsonDecode(resSeineOuest.body);
      final recs = data['results'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromSeineOuestJson(r)));
    }

    // 5. Nantes Métropole - Ecopoints
    final urlNantes =
        'https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/244400404_decheteries-ecopoints-nantes-metropole/records'
        '?where=code_postal="$codePostal"&limit=100';

    final resNantes = await http.get(Uri.parse(urlNantes));
    if (resNantes.statusCode == 200) {
      final data = jsonDecode(resNantes.body);
      final recs = data['results'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromNantesJson(r)));
    }

    // 6. Colonnes aériennes Nantes
    final urlColonneNantes =
        'https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/244400404_localisation-des-colonnes-apports-volontaires-de-nantes-metropole/records'
        '?where=commune%3A"$commune"&limit=100';

    final resColonneNantes = await http.get(Uri.parse(urlColonneNantes));
    if (resColonneNantes.statusCode == 200) {
      final data = jsonDecode(resColonneNantes.body);
      final recs = data['results'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromColonneNantesJson(r)));
    }

    //7. URL de base Rennes
    final communeUpper = commune.toUpperCase(); // RENNES
    final urlRennes =
        'https://data.rennesmetropole.fr/api/explore/v2.1/catalog/datasets/points-apport-volontaire/records'
        '?where=adresse_complete like "%$communeUpper%"&limit=100';

    print(urlRennes);
    final resRennes = await http.get(Uri.parse(urlRennes));
    if (resRennes.statusCode == 200) {
      final data = jsonDecode(resRennes.body);
      final recs = data['results'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromRennesJson(r, commune)));
    }

    //8. URL de base Rennes
    final urlRennes2 =
        'https://data.rennesmetropole.fr/api/explore/v2.1/catalog/datasets/points-regroupement-bacs-roulants/records'
        '?where=adresse_complete like "%$communeUpper%"&limit=100';


    print(urlRennes2);
    final resRennes2 = await http.get(Uri.parse(urlRennes2));
    if (resRennes2.statusCode == 200) {
      final data = jsonDecode(resRennes2.body);
      final recs = data['results'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromRennes2Json(r, commune)));
    }

    return points;
  }


}
