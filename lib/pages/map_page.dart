import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../API/map/pointCollecte.dart';
import '../services/map_service.dart';
import '../services/product_service.dart';
import '../utils/snackBar_util.dart';
import '../utils/theme_util.dart';
import '../widgets/loading_widget.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  final String codePostal;
  final String commune;

  const MapPage({
    Key? key,
    required this.codePostal,
    required this.commune,
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<CollectionPoint> _stations = [];
  bool _loading = true;
  CollectionPoint? _selected;
  bool _showFilters = false;
  List<Map<String, dynamic>> _packagings = [];

  final Map<String, bool> _filters = {
    "glass": true,
    "plastic": true,
    "metal": true,
    "paper-or-cardboard": true,
    "non-recyclable": true,
  };

  final _productService = ProductService();
  Map<String, BitmapDescriptor> _iconsCache = {};
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final stations = await MapService.fetchStationsByPostal(widget.codePostal, widget.commune);
      for (var station in stations) {
        _iconsCache[station.icone] = await _loadMarkerIcon(station.icone);
      }

      LatLng initial;

      if (stations.isNotEmpty) {
        initial = LatLng(stations[0].latitude, stations[0].longitude);
      } else {
        try {
          final locations = await locationFromAddress("${widget.codePostal} ${widget.commune}");
          initial = LatLng(locations[0].latitude, locations[0].longitude);
        } catch (_) {
          initial = const LatLng(48.8566, 2.3522);
        }
      }

      setState(() {
        _stations = stations;
        _loading = false;
        _initialPosition = initial;
      });
    } catch (e) {
      print('Erreur: $e');
      setState(() {
        _stations = [];
        _loading = false;
        _initialPosition = const LatLng(48.8566, 2.3522);
      });
    }
  }

  List<CollectionPoint> get _filteredStations {
    return _stations.where((s) {
      return s.types.any((t) => _filters[t] == true);
    }).toList();
  }

  String _typeLabel(String type) {
    switch (type) {
      case "glass":
        return "Verre";
      case "plastic":
        return "Plastique";
      case "metal":
        return "Métal";
      case "paper-or-cardboard":
        return "Papier/Carton";
      case "non-recyclable":
        return "Non recyclable";
      default:
        return type;
    }
  }

  Future<void> _loadPackagings(List<String> types) async {
    try {
      final results = await _productService.fetchPackagingsByTypes(types);
      setState(() {
        _packagings = results;
      });
    } catch (e) {
      print("❌ Erreur chargement packagings: $e");
    }
  }

  Future<BitmapDescriptor> _loadMarkerIcon(String assetPath, {int size = 90}) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: size,
      targetHeight: size,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? resized = await fi.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(resized!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _initialPosition == null) return const LoadingScreen();

    final filtered = _filteredStations;

    return Scaffold(
      appBar: buildCustomAppBar(context, "Points de Collecte"),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: filtered.isNotEmpty
                  ? LatLng(filtered[0].latitude, filtered[0].longitude)
                  : _initialPosition!,
              zoom: 16,
            ),
            markers: filtered.map((s) {
              return Marker(
                markerId: MarkerId(s.id),
                position: LatLng(s.latitude, s.longitude),
                icon: _iconsCache[s.icone] ?? BitmapDescriptor.defaultMarker,
                onTap: () async {
                  setState(() => _selected = s);
                  await _loadPackagings(s.types);
                },
              );
            }).toSet(),
          ),

          buildFancyHeader('${widget.commune} (${widget.codePostal})'),

          Positioned(
            top: 120,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              child: const Icon(Icons.filter_list, color: cardColor),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ),

          if (_showFilters)
            Positioned(
              top: 180,
              right: 10,
              child: Card(
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        title: const Text("Tous"),
                        value: !_filters.values.contains(false),
                        activeColor: primaryColor,
                        onChanged: (val) =>
                            setState(() => _filters.updateAll((key, value) => val ?? true)),
                      ),
                      ..._filters.keys.map((type) {
                        return CheckboxListTile(
                          title: Text(_typeLabel(type)),
                          activeColor: primaryColor,
                          value: _filters[type],
                          onChanged: (val) => setState(() => _filters[type] = val ?? true),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

          if (_selected != null)
            Positioned(
              top: 120,
              left: 10,
              child: SizedBox(
                width: 220,
                child: Card(
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          _selected!.icone,
                          width: 40,
                          height: 40,
                          errorBuilder: (ctx, error, stack) =>
                          const Icon(Icons.location_on, size: 40, color: primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(_selected!.nom,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87)),
                        Text(_selected!.adresse, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('Types: ${_selected!.types.map(_typeLabel).join(", ")}',
                            style: const TextStyle(color: Colors.black54)),
                        Text('Code postal: ${_selected!.codePostal}'),
                        Text(_selected!.description,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_packagings.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 200,
                child: Container(
                  color: Colors.transparent,
                  margin: const EdgeInsets.all(8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _packagings.length,
                    itemBuilder: (ctx, i) {
                      final p = _packagings[i];
                      final product = p["products"] ?? {};
                      final material = p["materials"] ?? {};

                      final numberOfUnits = p["number_of_units"] ?? 1;
                      final qpu = p["quantity_per_unit"] ?? "";
                      final packagingMaterial = p["material"] ?? "-";
                      final weightMeasured = p["weight_measured"]?.toString() ?? "-";

                      return Container(
                        width: 250,
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                          ],
                          border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product["name"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (product["image_url"] != null)
                                  Image.network(product["image_url"], height: 60, width: 120, fit: BoxFit.cover)
                                else
                                  Container(height: 60, width: 120, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                                StatefulBuilder(
                                  builder: (context, setStateSwitch) {
                                    return Switch(
                                      value: p["to_throw"] ?? false,
                                      activeColor: primaryColor,
                                      onChanged: (newValue) async {
                                        setStateSwitch(() => p["to_throw"] = newValue);
                                        final confirmedValue = await _productService.updateToThrow(p["id"], newValue);
                                        if (confirmedValue != null) {
                                          setState(() => p["to_throw"] = confirmedValue);
                                          if (!mounted) return;
                                          showCustomSnackBar(context,
                                              confirmedValue ? "Emballage jeté " : "Emballage non jeté ");
                                        } else {
                                          setStateSwitch(() => p["to_throw"] = !newValue);
                                          if (!mounted) return;
                                          showCustomSnackBar(context, "Erreur lors de la mise à jour");
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: "Emballage: "),
                                  TextSpan(text: p["name"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "  $numberOfUnits × $qpu ($packagingMaterial)"),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: "Matériau: "),
                                  TextSpan(text: material["type"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
