import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/theme_util.dart';
import 'detailProduct_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  bool _hasScanned = false;
  bool _flashOn = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BuildContext context, BarcodeCapture capture) {
    if (_hasScanned) return;

    // Vérifie qu’on a bien détecté au moins un code
    if (capture.barcodes.isEmpty) return;

    final String? code = capture.barcodes.first.rawValue;
    debugPrint("📸 Code détecté : $code");

    if (code != null && code.isNotEmpty && RegExp(r'^\d+$').hasMatch(code)) {
      setState(() => _hasScanned = true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailProductPage(barcode: code),
        ),
      ).then((_) {
        Navigator.pop(context, true);
      });

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(context,"Scanner un produit"),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) => _onDetect(context, capture),
            controller: MobileScannerController(
              facing: _cameraFacing,
              torchEnabled: _flashOn,
            ),
          ),

          Center(
            child: Container(
              width: 350,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Align(
                    alignment:
                    Alignment(0, _animation.value * 2 - 1),
                    child: Container(
                      width: double.infinity,
                      height: 2,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "flash",
                  backgroundColor:
                  _flashOn ? Colors.yellow.shade700 : Colors.black54,
                  onPressed: () {
                    setState(() => _flashOn = !_flashOn);
                  },
                  child: Icon(
                    _flashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                ),

                FloatingActionButton(
                  heroTag: "camera",
                  backgroundColor: Colors.black54,
                  onPressed: () {
                    setState(() {
                      _cameraFacing = _cameraFacing == CameraFacing.back
                          ? CameraFacing.front
                          : CameraFacing.back;
                    });
                  },
                  child: const Icon(Icons.cameraswitch, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
