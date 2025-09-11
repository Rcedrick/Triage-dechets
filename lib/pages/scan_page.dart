import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/customise_utils.dart';
import '../utils/theme_util.dart';
import 'detailProduct_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _hasScanned = false; // ✅ flag pour éviter les doublons

  void _onDetect(BuildContext context, BarcodeCapture capture) {
    if (_hasScanned) return; // déjà traité → on ignore

    final String? code = capture.barcodes.first.rawValue;
    debugPrint("📌 Code scanné : $code");

    if (code != null && code.isNotEmpty) {
      setState(() => _hasScanned = true); // ✅ stop les prochains scans

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DetailProductPage(barcode: code),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar("Scanner un produit"),
      body: MobileScanner(
        onDetect: (capture) => _onDetect(context, capture),
      ),
    );
  }
}
