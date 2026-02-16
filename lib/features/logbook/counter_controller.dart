import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => List.unmodifiable(_history);

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('last_counter') ?? 0;

    final historyData = prefs.getString('history_list');
    if (historyData != null) {
      final decoded = jsonDecode(historyData) as List;
      _history.clear();
      _history.addAll(decoded.cast<String>());
    }
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_counter', _counter);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('history_list', jsonEncode(_history));
  }

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  Future<void> _addHistory(String message, String username) async {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    _history.add('[$time] User $username $message');

    if (_history.length > 5) {
      _history.removeAt(0);
    }

    await _saveHistory();
  }

  Future<void> increment(String username) async {
    _counter += _step;
    await _saveCounter();
    await _addHistory("menambah +$_step", username);
  }

  Future<void> decrement(String username) async {
    if (_counter - _step >= 0) {
      _counter -= _step;
      await _saveCounter();
      await _addHistory("mengurangi -$_step", username);
    }
  }

  Future<void> reset(String username) async {
    _counter = 0;
    await _saveCounter();
    await _addHistory("mereset counter", username);
  }
}
