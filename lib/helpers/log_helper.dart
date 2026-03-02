import 'dart:developer' as dev;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    final int configLevel =
        int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      final DateTime now = DateTime.now();

      final String timeStampConsole =
          DateFormat('HH:mm:ss').format(now);
      final String dateStampFile =
          DateFormat('dd-MM-yyyy').format(now);

      final String label = _getLabel(level);
      final String color = _getColor(level);

      final String formattedMessage =
          "[$timeStampConsole][$label][$source] -> $message";

      dev.log(message,
          name: source, time: now, level: level * 100);

      print('$color$formattedMessage\x1B[0m');

      final Directory logDir = Directory('logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final File logFile =
          File('logs/$dateStampFile.log');

      final String fileEntry =
          "[${DateFormat('HH:mm:ss').format(now)}][$label][$source] -> $message\n";

      await logFile.writeAsString(
        fileEntry,
        mode: FileMode.append,
      );
    } catch (e) {
      dev.log("Logging failed: $e",
          name: "SYSTEM", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m';
      case 2:
        return '\x1B[32m';
      case 3:
        return '\x1B[34m';
      default:
        return '\x1B[0m';
    }
  }
}