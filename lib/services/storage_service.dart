import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_model.dart';

class StorageService {
  static const String _key = 'qr_history';

  // 1. CREATE
  Future<void> saveRecord(HistoryModel record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getHistory();
    records.add(record);
    await prefs.setString(_key, jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  // 2. READ
  Future<List<HistoryModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => HistoryModel.fromJson(json)).toList();
    }
    return [];
  }

  // 3. DELETE (This fixes your undefined_method error!)
  Future<void> deleteRecords(List<HistoryModel> recordsToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getHistory();
    
    // Create a set of unique timestamps to identify which ones to delete
    final timestampsToDelete = recordsToDelete.map((r) => r.timestamp.toIso8601String()).toSet();
    
    // Remove matches
    records.removeWhere((record) => timestampsToDelete.contains(record.timestamp.toIso8601String()));
    
    // Save the updated list back to the device
    await prefs.setString(_key, jsonEncode(records.map((r) => r.toJson()).toList()));
  }

Future<void> clearAll() async {
  final prefs = await SharedPreferences.getInstance();
  // Use the static _key constant instead of the wrong string
  await prefs.remove(_key); 
}
}