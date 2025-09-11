import 'dart:convert';
import 'package:http/http.dart' as http;
import '../API/pointCollecte.dart';

class MapService {
  static Future<List<CollectionPoint>> fetchStationsByPostal(String codePostal,String commune ) async {
    final List<CollectionPoint> points = [];

    // 1. Trilib API
    final urlTrilib =
        'https://opendata.paris.fr/api/records/1.0/search/'
        '?dataset=dechets-menagers-points-dapport-volontaire-stations-trilib'
        '&refine.code_postal=$codePostal'
        '&rows=100';
    //final urlTrilib = 'https://opendata.paris.fr/api/records/1.0/search/?dataset=dechets-menagers-points-dapport-volontaire-stations-trilib&refine.code_postal=75005&rows=100';

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
    //final urlVerre = https://opendata.paris.fr/api/records/1.0/search/?dataset=dechets-menagers-points-dapport-volontaire-colonnes-a-verre&refine.arrdt=75010&rows=100

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
    //final urlAngers ='https://data.angers.fr/api/explore/v2.1/catalog/datasets/point-apport-volontaire-dechets/records?where=nom_commune%3D%27ANGERS%27&limit=100';

    final resAngers = await http.get(Uri.parse(urlAngers));
    if (resAngers.statusCode == 200) {
      final data = jsonDecode(resAngers.body);
      final recs = data['results'] as List;
      points.addAll(recs.map((r) => CollectionPoint.fromAngersJson(r)));
    }

    return points;
  }
}
