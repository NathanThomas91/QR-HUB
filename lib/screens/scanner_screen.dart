import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/custom_button.dart';
import '../models/history_model.dart';
import '../services/storage_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  
  bool _isScanned = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startTimeoutTimer();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 8), () { // 8-second timeout
      if (mounted && !_isScanned) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No QR code detected. Make sure it is well-lit and centered.'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _showTopSuccessToast() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: -100, end: MediaQuery.of(context).padding.top + 16),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Positioned(top: value, left: 20, right: 20, child: child!),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)]),
              child: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 16), Expanded(child: Text('Code recognized & auto-saved', style: TextStyle(color: Colors.white)))]),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () { if (entry.mounted) entry.remove(); });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty || barcodes.first.rawValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid code detected.')));
      return;
    }

    final String code = barcodes.first.rawValue!;
    _timeoutTimer?.cancel();
    
    setState(() => _isScanned = true);
    _scannerController.stop(); 

    final record = HistoryModel(content: code, type: 'Scanned', timestamp: DateTime.now());
    await StorageService().saveRecord(record);

    if (mounted) {
      _showTopSuccessToast();
      _showResultSheet(code);
    }
  }

  void _showResultSheet(String code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('QR Code Detected', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)), child: Text(code, textAlign: TextAlign.center)),
            const SizedBox(height: 24),
            // Copy Option
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
              },
              icon: const Icon(Icons.copy), label: const Text('Copy Content'),
            ),
            const SizedBox(height: 16),
            CustomButton(title: 'Rescan', icon: Icons.qr_code_scanner_rounded, onTap: () => Navigator.pop(context)),
            // Return to Home in Red
            TextButton.icon(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.home_rounded, color: Colors.redAccent),
              label: const Text('Return to Home', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isScanned = false);
        _scannerController.start();
        _startTimeoutTimer();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code'), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_photography_rounded, size: 64, color: Colors.redAccent),
                  const Text('Camera Access Denied', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  CustomButton(title: 'Go Back', onTap: () => Navigator.pop(context), icon: Icons.arrow_back),
                ],
              ),
            ),
          ),
          if (!_isScanned)
             Center(child: Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor, width: 4), borderRadius: BorderRadius.circular(24)))),
        ],
      ),
    );
  }
}