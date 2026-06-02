import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/history_model.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryModel> _historyRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final records = await StorageService().getHistory();
    if (mounted) {
      setState(() {
        _historyRecords = records.reversed.toList();
        _isLoading = false;
      });
    }
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All?'),
        content: const Text('Are you sure you want to clear your entire history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await StorageService().clearAll(); // Delete data
              await _loadHistory(); // Refresh the list
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllToCSV() async {
    final path = (await getTemporaryDirectory()).path;
    final file = File('$path/QR_History.csv');
    String content = "Type,Content,Timestamp\n${_historyRecords.map((r) => "${r.type},\"${r.content.replaceAll('"', '""')}\",${r.timestamp}").join('\n')}";
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: 'My Full QR History');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Log'),
        actions: [
          if (_historyRecords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _confirmDeleteAll,
            ),
        ],
      ),
      floatingActionButton: _historyRecords.isEmpty ? null : FloatingActionButton.extended(
        onPressed: _exportAllToCSV,
        icon: const Icon(Icons.ios_share_rounded),
        label: const Text("Export CSV"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _historyRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_edu_rounded, size: 100, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text("No History Found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _historyRecords.length,
                  itemBuilder: (context, index) {
                    final record = _historyRecords[index];
                    final isScanned = record.type.toLowerCase() == 'scanned';

                    return Dismissible(
                      key: Key(record.timestamp.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await StorageService().deleteRecords([record]);
                        await _loadHistory();
                      },
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onTap: () => _showPremiumDetailSheet(record),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: (isScanned ? Colors.amber : Colors.blue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(isScanned ? Icons.qr_code_scanner : Icons.qr_code, color: isScanned ? Colors.amber : Colors.blue),
                            ),
                            title: Text(record.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${record.type} • ${record.timestamp.toString().substring(0, 16)}'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showPremiumDetailSheet(HistoryModel record) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]),
            child: QrImageView(data: record.content, size: 180, foregroundColor: record.type == 'Scanned' ? Colors.amber : Colors.blue),
          ),
          const SizedBox(height: 24),
          Text(record.content, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.calendar_today), title: Text("Date: ${record.timestamp}")),
          ListTile(leading: const Icon(Icons.category), title: Text("Type: ${record.type}")),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.copy_all_rounded), label: const Text('Copy Content'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: () { Clipboard.setData(ClipboardData(text: record.content)); Navigator.pop(context); },
            ),
          )
        ]),
      ),
    );
  }
}