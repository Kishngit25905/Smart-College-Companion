import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:convert';
import 'dart:io';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notes_v2');
    if (data != null) {
      setState(() {
        notes = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_v2', jsonEncode(notes));
  }

  // Pick PDF from phone storage
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          notes.add({
            'title': file.name,
            'subject': 'Uncategorized',
            'content': '',
            'type': 'PDF',
            'path': file.path,
            'size': file.size,
            'date': DateTime.now().toIso8601String(),
          });
        });
        _saveData();

        // Ask user to set subject
        _editSubject(notes.length - 1);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  // Add text note manually
  void _addTextNote(String title, String subject, String content) {
    setState(() {
      notes.add({
        'title': title,
        'subject': subject,
        'content': content,
        'type': 'Note',
        'path': '',
        'size': 0,
        'date': DateTime.now().toIso8601String(),
      });
    });
    _saveData();
  }

  // Add link
  void _addLink(String title, String subject, String url) {
    setState(() {
      notes.add({
        'title': title,
        'subject': subject,
        'content': url,
        'type': 'Link',
        'path': '',
        'size': 0,
        'date': DateTime.now().toIso8601String(),
      });
    });
    _saveData();
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    _saveData();
  }

  // Open PDF using device's default PDF viewer
  Future<void> _openPDF(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open PDF. No PDF viewer found.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File not found. It may have been moved or deleted.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editSubject(int index) {
    final controller = TextEditingController(text: notes[index]['subject']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subject Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.book_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                notes[index]['subject'] = controller.text;
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              icon: Icons.picture_as_pdf_outlined,
              color: const Color(0xFFEF4444),
              title: 'Import PDF from Phone',
              subtitle: 'Pick any PDF from your storage',
              onTap: () {
                Navigator.pop(context);
                _pickPDF();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.note_outlined,
              color: const Color(0xFF8B5CF6),
              title: 'Write a Note',
              subtitle: 'Type text notes manually',
              onTap: () {
                Navigator.pop(context);
                _showAddNoteDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.link,
              color: const Color(0xFF3B82F6),
              title: 'Save a Link',
              subtitle: 'YouTube, Drive, or any URL',
              onTap: () {
                Navigator.pop(context);
                _showAddLinkDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addTextNote(
                  titleController.text,
                  subjectController.text.isEmpty
                      ? 'General'
                      : subjectController.text,
                  contentController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddLinkDialog() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save a Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL / Link',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                _addLink(
                  titleController.text,
                  subjectController.text.isEmpty
                      ? 'General'
                      : subjectController.text,
                  urlController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'PDF': return const Color(0xFFEF4444);
      case 'Link': return const Color(0xFF3B82F6);
      default: return const Color(0xFF8B5CF6);
    }
  }

  IconData _typeIconData(String type) {
    switch (type) {
      case 'PDF': return Icons.picture_as_pdf_outlined;
      case 'Link': return Icons.link;
      default: return Icons.note_outlined;
    }
  }

  void _viewNote(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                note['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(note['subject'],
                  style: const TextStyle(color: Colors.grey)),
              const Divider(height: 24),
              if (note['type'] == 'Note')
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Text(
                      note['content'].isEmpty
                          ? 'No content added.'
                          : note['content'],
                      style:
                          const TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ),
                ),
              if (note['type'] == 'PDF') ...[
                const Text('PDF File saved in your app.'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPDF(note['path']),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              if (note['type'] == 'Link') ...[
                const Text('Saved Link:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    note['content'],
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & PDFs'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${notes.length} items',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptions,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: notes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notes yet!',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add PDFs, Notes or Links',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final color = _typeColor(note['type']);
                final date = DateTime.parse(note['date']);

                return GestureDetector(
                  onTap: () => note['type'] == 'PDF'
                      ? _openPDF(note['path'])
                      : _viewNote(note),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_typeIconData(note['type']),
                            color: color, size: 26),
                      ),
                      title: Text(
                        note['title'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text(note['subject'],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11),
                              ),
                              if (note['type'] == 'PDF' &&
                                  note['size'] > 0) ...[
                                const Text('  ·  ',
                                    style:
                                        TextStyle(color: Colors.grey)),
                                Text(
                                  _formatSize(note['size']),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              note['type'],
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () => _deleteNote(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}