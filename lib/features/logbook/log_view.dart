import 'package:flutter/material.dart';
import 'package:logbook_app_004/services/mongo_service.dart';
import '../auth/login_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'widgets/log_item_widget.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  late Future<void> _initialLoad;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = "Pribadi";
  String _searchQuery = "";

  final List<String> _categories = [
    "Pekerjaan",
    "Pribadi",
    "Urgent",
  ];

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username);
    _initialLoad = _initApp();
  }

  Future<void> _initApp() async {
    await MongoService().connect();
    await _controller.fetchLogs();
  }

  Future<void> _refresh() async {
    await _controller.fetchLogs();
  }

  void _confirmLogout() async {
    await MongoService().close();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  void _showAddDialog() {
    _titleController.clear();
    _descController.clear();
    _selectedCategory = "Pribadi";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
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
            onPressed: () async {
              await _controller.addLog(
                _titleController.text,
                _descController.text,
                _selectedCategory,
              );
              if (!mounted) return;
              Navigator.pop(context);
              await _refresh();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(LogModel log) {
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
            onPressed: () async {
              await _controller.updateLogById(
                log.id!,
                _titleController.text,
                _descController.text,
                _selectedCategory,
              );
              if (!mounted) return;
              Navigator.pop(context);
              await _refresh();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  List<LogModel> _applySearch(List<LogModel> logs) {
    if (_searchQuery.isEmpty) return logs;
    return logs.where((log) {
      return log.title.toLowerCase().contains(_searchQuery) ||
          log.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF6A5AE0), 
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Logbook: ${widget.username}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout,
                        color: Colors.white),
                    onPressed: _confirmLogout,
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Cari catatan...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<void>(
                future: _initialLoad,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            "Sinkronisasi dengan MongoDB Atlas...",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<LogModel>>(
                    valueListenable: _controller.logsNotifier,
                    builder: (context, logs, _) {
                      final filteredLogs =
                          _applySearch(logs);

                      if (filteredLogs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off,
                                  size: 80,
                                  color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                  "Belum ada catatan di Cloud."),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _showAddDialog,
                                child: const Text(
                                    "Buat Catatan Pertama"),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          itemCount: filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log =
                                filteredLogs[index];

                            return Dismissible(
                              key: Key(
                                  log.id!.toHexString()),
                              direction:
                                  DismissDirection
                                      .endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment:
                                    Alignment.centerRight,
                                padding:
                                    const EdgeInsets.only(
                                        right: 20),
                                child: const Icon(
                                    Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) async {
                                await _controller
                                    .deleteById(
                                        log.id!);
                                await _refresh();
                              },
                              child: LogItemWidget(
                                log: log,
                                onEdit: () =>
                                    _showEditDialog(
                                        log),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            const Color(0xFF6A5AE0),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}