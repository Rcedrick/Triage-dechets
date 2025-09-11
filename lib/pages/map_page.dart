import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../API/pointCollecte.dart';
import '../services/map_service.dart';
import '../services/product_service.dart';
import '../utils/customise_utils.dart';
import '../utils/theme_util.dart';

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
    "paper-cardboard": true,
    "non-recyclable": true,
  };

  final _productService = ProductService();
  Map<String, BitmapDescriptor> _iconsCache = {};

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final l = await MapService.fetchStationsByPostal(widget.codePostal, widget.commune);

      for (var station in l) {
        _iconsCache[station.icone] = await _loadMarkerIcon(station.icone);
      }

      setState(() {
        _stations = l;
        _loading = false;
      });
    } catch (e) {
      print('Erreur: $e');
      setState(() => _loading = false);
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
      case "paper-cardboard":
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

  Future<BitmapDescriptor> _loadMarkerIcon(String assetPath, {int size = 140}) async {
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filteredStations;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: filtered.isNotEmpty
                  ? LatLng(filtered[0].latitude, filtered[0].longitude)
                  : const LatLng(48.8566, 2.3522),
              zoom: 13,
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
              onPressed: () {
                setState(() => _showFilters = !_showFilters);
              },
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
                        onChanged: (val) {
                          setState(() {
                            _filters.updateAll((key, value) => val ?? true);
                          });
                        },
                      ),
                      ..._filters.keys.map((type) {
                        return CheckboxListTile(
                          title: Text(_typeLabel(type)),
                          value: _filters[type],
                          onChanged: (val) {
                            setState(() => _filters[type] = val ?? true);
                          },
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
                          const Icon(Icons.location_on, size: 40),
                        ),
                        const SizedBox(height: 8),
                        Text(_selected!.nom,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_selected!.adresse),
                        const SizedBox(height: 4),
                        Text('Types: ${_selected!.types.map(_typeLabel).join(", ")}'),
                        Text('Code postal: ${_selected!.codePostal}'),
                        Text(_selected!.description,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 12)),
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
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: cardColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product["name"] ?? "-",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (product["image_url"] != null)
                                  Image.network(
                                    product["image_url"],
                                    height: 60,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  Container(
                                    height: 60,
                                    width: 120,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported),
                                  ),

                                StatefulBuilder(
                                  builder: (context, setStateSwitch) {
                                    return Switch(
                                      value: p["to_throw"] ?? false,
                                      activeColor: primaryColor,
                                      onChanged: (newValue) async {
                                        setStateSwitch(() => p["to_throw"] = newValue);

                                        final confirmedValue =
                                        await _productService.updateToThrow(p["id"], newValue);

                                        if (confirmedValue != null) {
                                          setState(() => p["to_throw"] = confirmedValue);
                                          if (!mounted) return;
                                          showCustomSnackBar(
                                            context,
                                            confirmedValue
                                                ? "Emballage jeté "
                                                : "Emballage non jeté ",
                                          );
                                        } else {
                                          setStateSwitch(() => p["to_throw"] = !newValue);
                                          if (!mounted) return;
                                          showCustomSnackBar(
                                              context, "Erreur lors de la mise à jour");
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
                                style: const TextStyle(color: Colors.black), // style par défaut
                                children: [
                                  const TextSpan(text: "Emballage: "),
                                  TextSpan(
                                    text: p["name"] ?? "-",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "  $numberOfUnits × $qpu ($packagingMaterial: $weightMeasured g)",
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: "Matériau: "),
                                  TextSpan(
                                    text: material["type"] ?? "-",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
