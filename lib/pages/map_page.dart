import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../API/map/pointCollecte.dart';
import '../services/map_service.dart';
import '../services/product_service.dart';
import '../utils/material_categories.dart';
import '../utils/snackBar_util.dart';
import '../utils/theme_util.dart';
import '../widgets/loading_widget.dart';

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

  // ✅ FILTRES DYNAMIQUES basés sur MaterialCategories
  final Map<String, bool> _filters = {
    for (final category in MaterialCategories.all) category.id: true,
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

      // Charger les icônes pour chaque station
      for (var station in stations) {
        _iconsCache[station.icone] = await _loadMarkerIcon(station.icone);
      }

      // Déterminer la position initiale
      LatLng initial;
      if (stations.isNotEmpty) {
        initial = LatLng(stations[0].latitude, stations[0].longitude);
      } else {
        try {
          final locations = await locationFromAddress("${widget.codePostal} ${widget.commune}");
          initial = LatLng(locations[0].latitude, locations[0].longitude);
        } catch (_) {
          initial = const LatLng(48.8566, 2.3522); // Paris par défaut
        }
      }

      setState(() {
        _stations = stations;
        _loading = false;
        _initialPosition = initial;
      });
    } catch (e) {
      print('Erreur chargement stations: $e');
      setState(() {
        _stations = [];
        _loading = false;
        _initialPosition = const LatLng(48.8566, 2.3522);
      });
    }
  }

  // ✅ STATIONS FILTRÉES utilisant MaterialCategories
  List<CollectionPoint> get _filteredStations {
    return _stations.where((station) {
      return station.types.any((type) => _filters[type] == true);
    }).toList();
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
    try {
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
    } catch (e) {
      print("❌ Erreur chargement icône: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  Widget _buildFiltersPanel() {
    return Positioned(
      top: 180,
      right: 10,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text(
                  "Tous",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                value: !_filters.values.contains(false),
                activeColor: primaryColor,
                onChanged: (val) => setState(() {
                  _filters.updateAll((key, value) => val ?? true);
                }),
              ),

              const Divider(height: 4, thickness: 1),

              ...MaterialCategories.all.map((category) {
                return CheckboxListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  visualDensity: VisualDensity.compact,
                  title: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  activeColor: primaryColor,
                  value: _filters[category.id],
                  onChanged: (val) => setState(() => _filters[category.id] = val ?? true),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationInfo() {
    if (_selected == null) return const SizedBox.shrink();

    return Positioned(
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      _selected!.icone,
                      width: 40,
                      height: 40,
                      errorBuilder: (ctx, error, stack) =>
                      const Icon(Icons.location_on, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selected!.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Adresse
                Text(
                  _selected!.adresse,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 4),

                // Dans la partie types :
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _selected!.types.map((type) {
                    final category = MaterialCategories.getById(type);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: category.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),

                // Description
                if (_selected!.description.isNotEmpty)
                  Text(
                    _selected!.description,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackagingsPanel() {
    if (_packagings.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
          ),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _packagings.length,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemBuilder: (ctx, index) {
            final p = _packagings[index];
            final product = p["products"] ?? {};
            final material = p["materials"] ?? {};
            final numberOfUnits = p["number_of_units"] ?? 1;
            final qpu = p["quantity_per_unit"] ?? "";
            final packagingMaterial = p["material"] ?? "-";

            return Container(
              width: 250,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec nom et switch
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product["name"] ?? "Produit inconnu",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                                  showCustomSnackBar(
                                    context,
                                    confirmedValue ? "✅ Emballage jeté" : "🔄 Emballage conservé",
                                  );
                                } else {
                                  setStateSwitch(() => p["to_throw"] = !newValue);
                                  if (!mounted) return;
                                  showCustomSnackBar(context, "❌ Erreur lors de la mise à jour");
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Image et détails
                    Expanded(
                      child: Row(
                        children: [
                          // Image du produit
                          if (product["image_url"] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product["image_url"],
                                height: 60,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stack) =>
                                    Container(
                                      height: 60,
                                      width: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_not_supported, size: 24),
                                    ),
                              ),
                            )
                          else
                            Container(
                              height: 60,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image_not_supported, size: 24),
                            ),

                          const SizedBox(width: 8),

                          // Détails de l'emballage
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "📦 ${p["name"] ?? "Emballage"}",
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "🔢 $numberOfUnits × $qpu",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                Text(
                                  "🧱 $packagingMaterial",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                if (material["type"] != null)
                                  Text(
                                    "🏷️ ${material["type"]}",
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _initialPosition == null) {
      return const LoadingScreen();
    }

    final filteredStations = _filteredStations;

    return Scaffold(
      appBar: buildCustomAppBar(context, "Points de Collecte"),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: filteredStations.isNotEmpty
                  ? LatLng(filteredStations[0].latitude, filteredStations[0].longitude)
                  : _initialPosition!,
              zoom: 14,
            ),
            markers: filteredStations.map((station) {
              return Marker(
                markerId: MarkerId(station.id),
                position: LatLng(station.latitude, station.longitude),
                icon: _iconsCache[station.icone] ?? BitmapDescriptor.defaultMarker,
                onTap: () async {
                  setState(() => _selected = station);
                  await _loadPackagings(station.types);
                },
              );
            }).toSet(),
          ),

          buildFancyHeader('${widget.commune} (${widget.codePostal})'),

          // Bouton filtre
          Positioned(
            top: 120,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              mini: true,
              child: Icon(
                _showFilters ? Icons.close : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ),

          if (_showFilters) _buildFiltersPanel(),

          _buildStationInfo(),

          _buildPackagingsPanel(),
        ],
      ),
    );
  }
}