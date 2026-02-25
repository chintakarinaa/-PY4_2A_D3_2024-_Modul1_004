import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  static const String _storageKey = 'user_logs_data';

  LogController() {
    loadFromDisk();
  }

  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
    );

    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  void updateLog(int index, String title, String desc, String category) {
    final current = List<LogModel>.from(logsNotifier.value);

    current[index] = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
    );

    logsNotifier.value = current;
    filteredLogs.value = current;
    saveToDisk();
  }

  void removeLog(int index) {
    final current = List<LogModel>.from(logsNotifier.value);
    current.removeAt(index);

    logsNotifier.value = current;
    filteredLogs.value = current;
    saveToDisk();
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) =>
              log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      logsNotifier.value.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      final logs =
          decoded.map((e) => LogModel.fromMap(e)).toList();

      logsNotifier.value = logs;
      filteredLogs.value = logs;
    }
  }
}