import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_button.dart';
import '../models/history_model.dart';
import '../services/storage_service.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  String _qrData = '';
  bool _isSaved = false;

  // Unified Scanner-style Top Toast
  void _showTopToast({required String title, required String message, bool isError = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    final color = isError ? Colors.red.shade600 : Colors.green.shade600;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_rounded;

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
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))]),
              child: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(message, style: const TextStyle(color: Colors.white, fontSize: 12))]))]),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () { if (entry.mounted) entry.remove(); });
  }

  void _generateQR() {
    if (_textController.text.trim().isEmpty) {
      _showTopToast(title: 'Error', message: 'Please enter text to generate.', isError: true);
      return;
    }
    setState(() {
      _qrData = _textController.text.trim();
      _isSaved = false;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveToHistory() async {
    if (_isSaved) return;
    final record = HistoryModel(content: _qrData, type: 'Generated', timestamp: DateTime.now());
    await StorageService().saveRecord(record);
    setState(() => _isSaved = true);
    _showTopToast(title: 'Success', message: 'Added to History database.');
  }

  Future<void> _saveImage() async {
    final dir = await getApplicationDocumentsDirectory();
    await _screenshotController.captureAndSave(dir.path, fileName: 'qr_${DateTime.now().millisecondsSinceEpoch}.png');
    if (mounted) _showTopToast(title: 'Exported', message: 'Saved to device album.');
  }

  Future<void> _shareQR() async {
    final dir = await getTemporaryDirectory();
    final path = await _screenshotController.captureAndSave(dir.path, fileName: 'share.png');
    if (path != null) await Share.shareXFiles([XFile(path)], text: 'Check out this QR code!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Code'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_qrData.isEmpty) ...[
              TextField(controller: _textController, decoration: const InputDecoration(labelText: 'Enter text or URL', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              CustomButton(title: 'Generate QR', icon: Icons.qr_code, onTap: _generateQR),
            ],
            if (_qrData.isNotEmpty) ...[
              Screenshot(controller: _screenshotController, child: Container(color: Colors.white, padding: const EdgeInsets.all(10), child: QrImageView(data: _qrData, size: 200))),
              const SizedBox(height: 30),
              CustomButton(title: 'Save to Album', icon: Icons.image, onTap: _saveImage),
              CustomButton(title: 'Share QR', icon: Icons.share, onTap: _shareQR),
              CustomButton(
                title: _isSaved ? 'Saved to History' : 'Save to History', 
                icon: _isSaved ? Icons.check_circle : Icons.save, 
                onTap: _saveToHistory
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home, color: Colors.red),
                label: const Text("Return to Home", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}