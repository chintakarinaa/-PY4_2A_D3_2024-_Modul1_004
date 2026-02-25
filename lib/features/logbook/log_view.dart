import 'package:flutter/material.dart';
import '../auth/login_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'widgets/log_item_widget.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedCategory = "Pribadi";

  final List<String> _categories = [
    "Pekerjaan",
    "Pribadi",
    "Urgent",
  ];

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(hintText: "Deskripsi"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                _selectedCategory = value!;
              },
              decoration: const InputDecoration(labelText: "Kategori"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              _controller.addLog(
                _titleController.text,
                _descController.text,
                _selectedCategory,
              );
              _titleController.clear();
              _descController.clear();
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _descController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _descController),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                _selectedCategory = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              _controller.updateLog(
                index,
                _titleController.text,
                _descController.text,
                _selectedCategory,
              );
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logbook Digital"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => _controller.searchLog(value),
              decoration: const InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, logs, _) {
                if (logs.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.12),
                          Image.asset(
                            "assets/images/noteskosong.png",
                            height: constraints.maxHeight * 0.45,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Belum ada catatan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 101, 61, 153),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    return Dismissible(
                      key: Key(log.date),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 28),
                      ),
                      onDismissed: (_) {
                        _controller.removeLog(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Catatan dihapus")),
                        );
                      },
                      child: LogItemWidget(
                        log: log,
                        onEdit: () =>
                            _showEditDialog(index, log),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}