import 'dart:convert';

class HistoryModel {
  final String content;
  final String type; // We will use 'Generated' or 'Scanned'
  final DateTime timestamp;

  HistoryModel({
    required this.content,
    required this.type,
    required this.timestamp,
  });

  // Convert our object into a Map
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Build our object from a Map
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      content: map['content'] ?? '',
      type: map['type'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  // Encode to JSON String for SharedPreferences
  String toJson() => json.encode(toMap());

  // Decode from JSON String
  factory HistoryModel.fromJson(String source) => 
      HistoryModel.fromMap(json.decode(source));
}