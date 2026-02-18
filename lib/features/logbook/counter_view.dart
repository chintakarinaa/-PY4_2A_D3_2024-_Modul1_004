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
    await _controller.loadData(widget.username);
    setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook: ${widget.username}"),
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
            Text(
              "${_getGreeting()}, ${widget.username}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Step",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final step = int.tryParse(value) ?? 1;
                _controller.setStep(step);
              },
            ),
            const SizedBox(height: 30),
            Text(
              '${_controller.value}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
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
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.increment(widget.username);
                    setState(() {});
                  },
                  child: const Text("+"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _showResetDialog,
                  child: const Text("Reset"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Aktivitas",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _controller.history.map((item) {
                  final bool isAdd = item.contains("menambah");
                  final bool isMinus = item.contains("mengurangi");

                  Color borderColor;
                  Color bgColor;
                  IconData icon;

                  if (isAdd) {
                    borderColor = Colors.green;
                    bgColor = Colors.green.withOpacity(0.1);
                    icon = Icons.arrow_upward;
                  } else if (isMinus) {
                    borderColor = Colors.red;
                    bgColor = Colors.red.withOpacity(0.1);
                    icon = Icons.arrow_downward;
                  } else {
                    borderColor = Colors.grey;
                    bgColor = Colors.grey.withOpacity(0.1);
                    icon = Icons.refresh;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: borderColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              color: borderColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
