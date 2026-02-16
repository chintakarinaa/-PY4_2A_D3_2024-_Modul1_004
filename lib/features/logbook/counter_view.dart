import 'package:flutter/material.dart';
import 'package:logbook_app_004/features/logbook/counter_controller.dart';
import 'package:logbook_app_004/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  final TextEditingController _stepController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.loadData();
    setState(() {});
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Reset"),
        content: const Text("Apakah kamu yakin ingin mereset counter?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _controller.reset(widget.username);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Ya, Reset"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingView(),
      ),
      (route) => false,
    );
  }

  Color _getHistoryColor(String text) {
    if (text.contains("menambah")) {
      return Colors.green;
    } else if (text.contains("mengurangi")) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Total Hitungan"),
            Text(
              '${_controller.value}',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nilai Step",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final step = int.tryParse(value) ?? 1;
                _controller.setStep(step);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _controller.decrement(widget.username);
                    setState(() {});
                  },
                  child: const Text("-"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.increment(widget.username);
                    setState(() {});
                  },
                  child: const Text("+"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _showResetDialog,
                  child: const Text("Reset"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Riwayat Aktivitas"),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _controller.history.map((item) {
                  return ListTile(
                    title: Text(
                      item,
                      style: TextStyle(
                        color: _getHistoryColor(item),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
