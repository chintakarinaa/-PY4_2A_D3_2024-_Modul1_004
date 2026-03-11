import 'package:flutter/material.dart';
import '../models/log_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback? onEdit;

  const LogItemWidget({
    super.key,
    required this.log,
    this.onEdit,
  });

  String _formatDate(String isoDate) {
    try {
      final clean = isoDate.split('.').first;
      final date = DateTime.parse(clean);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return "baru saja";
      }

      if (diff.inMinutes < 60) {
        return "${diff.inMinutes} menit yang lalu";
      }

      if (diff.inHours < 24) {
        return "${diff.inHours} jam yang lalu";
      }

      if (diff.inDays == 1) {
        return "kemarin";
      }

      return "${diff.inDays} hari yang lalu";
    } catch (e) {
      return "-";
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case "Electronic":
        return const Color.fromARGB(255, 111, 43, 170);
      case "Software":
        return const Color.fromARGB(255, 172, 113, 255);
      default:
        return const Color.fromARGB(255, 206, 175, 255);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(log.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  log.category,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: onEdit,
                )
            ],
          ),
          const SizedBox(height: 6),
          MarkdownBody(
            data: log.description,
            shrinkWrap: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.35,
              ),
              h1: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              h2: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              strong: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              em: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(log.date),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}