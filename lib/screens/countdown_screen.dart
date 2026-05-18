import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  List<Map<String, dynamic>> exams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('exams');
    if (data != null) {
      setState(() {
        exams = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exams', jsonEncode(exams));
  }

  void _addExam(String name, String subject, String date) {
    setState(() {
      exams.add({
        'name': name,
        'subject': subject,
        'date': date,
      });
      exams.sort((a, b) => a['date'].compareTo(b['date']));
    });
    _saveData();
  }

  void _deleteExam(int index) {
    setState(() {
      exams.removeAt(index);
    });
    _saveData();
  }

  int _daysLeft(String date) {
    final examDate = DateTime.parse(date);
    final now = DateTime.now();
    return examDate.difference(now).inDays;
  }

  Color _getColor(int daysLeft) {
    if (daysLeft < 0) return const Color(0xFF6B7280);
    if (daysLeft <= 3) return const Color(0xFFEF4444);
    if (daysLeft <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getEmoji(int daysLeft) {
    if (daysLeft < 0) return '✅';
    if (daysLeft == 0) return '🔥';
    if (daysLeft <= 3) return '😰';
    if (daysLeft <= 7) return '📚';
    return '😎';
  }

  void _showAddExamDialog() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Exam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exam Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
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
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                trailing: const Icon(Icons.edit),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(days: 365),
                    ),
                  );
                  if (picked != null) {
                    setStateDialog(() {
                      selectedDate = picked;
                    });
                  }
                },
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
                if (nameController.text.isNotEmpty &&
                    subjectController.text.isNotEmpty) {
                  _addExam(
                    nameController.text,
                    subjectController.text,
                    selectedDate.toIso8601String(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Countdown'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExamDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Exam'),
        backgroundColor: const Color(0xFFEC4899),
      ),
      body: exams.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No exams added yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your exam dates',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                final daysLeft = _daysLeft(exam['date']);
                final color = _getColor(daysLeft);
                final emoji = _getEmoji(daysLeft);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              Text(
                                daysLeft < 0
                                    ? 'Done'
                                    : daysLeft == 0
                                        ? 'Today'
                                        : '$daysLeft',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (daysLeft > 0)
                                Text(
                                  'days',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam['name'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exam['subject'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  daysLeft < 0
                                      ? 'Completed'
                                      : daysLeft == 0
                                          ? '🔥 Exam Today!'
                                          : daysLeft <= 3
                                              ? '😰 Almost there!'
                                              : daysLeft <= 7
                                                  ? '📚 Start studying!'
                                                  : '😎 Plenty of time',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteExam(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}