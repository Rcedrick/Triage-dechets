import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'detailProduct_page.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  void _onDetect(BuildContext context, BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue;
    if (code != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DetailProductPage(barcode: code)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un produit")),
      body: MobileScanner(
        onDetect: (capture) => _onDetect(context, capture),
      ),
    );
  }
}
