import 'package:flutter/material.dart';
import '../models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback onEdit;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onEdit,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Pekerjaan":
        return Colors.deepPurple;
      case "Urgent":
        return const Color.fromARGB(255, 105, 13, 167);
      default:
        return const Color.fromARGB(255, 186, 149, 255);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(log.category);

    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                ),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              log.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              log.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: onEdit,
              ),
            )
          ],
        ),
      ),
    );
  }
}