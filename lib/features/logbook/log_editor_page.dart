import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_004/features/logbook/models/log_model.dart';
import 'package:logbook_app_004/features/logbook/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TabController _tabController;

  bool _isPublic = false;
  String _category = "Mechanical";

  static const purple = Color.fromARGB(255, 104, 30, 184);

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.log?.title ?? '');

    _descController =
        TextEditingController(text: widget.log?.description ?? '');

    _isPublic = widget.log?.isPublic ?? false;
    _category = widget.log?.category ?? "Mechanical";

    _tabController = TabController(length: 2, vsync: this);

    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (widget.log == null) {
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        widget.currentUser['uid'],
        widget.currentUser['teamId'],
        _isPublic,
        _category,
      );
    } else {
      widget.controller.updateLog(
        widget.log!.id!,
        _titleController.text,
        _descController.text,
        _isPublic,
        _category,
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      hintText: hint ?? label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 181, 143, 255),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: purple,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      appBar: AppBar(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        title: Text(
          widget.log == null ? "Catatan Baru" : "Edit Catatan",
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Editor"),
            Tab(text: "Preview"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: _inputDecoration("", hint: "Judul"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _inputDecoration("", hint: "Kategori"),
                  items: const [
                    DropdownMenuItem(
                      value: "Mechanical",
                      child: Text("Mechanical"),
                    ),
                    DropdownMenuItem(
                      value: "Electronic",
                      child: Text("Electronic"),
                    ),
                    DropdownMenuItem(
                      value: "Software",
                      child: Text("Software"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _isPublic,
                  activeColor: purple,
                  onChanged: (v) {
                    setState(() {
                      _isPublic = v;
                    });
                  },
                  title: Text(
                    _isPublic ? "Public" : "Private",
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _descController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    decoration: _inputDecoration(
                      "",
                      hint: "Isi Catatan",
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Markdown(
              data: _titleController.text.isEmpty
                  ? _descController.text
                  : "# ${_titleController.text}\n\n${_descController.text}",
            ),
          ),
        ],
      ),
    );
  }
}