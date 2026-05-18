import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('attendance');
    if (data != null) {
      setState(() {
        subjects = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance', jsonEncode(subjects));
  }

  void _addSubject(String name, int required) {
    setState(() {
      subjects.add({
        'name': name,
        'present': 0,
        'absent': 0,
        'required': required,
      });
    });
    _saveData();
  }

  void _markAttendance(int index, bool present) {
    setState(() {
      if (present) {
        subjects[index]['present']++;
      } else {
        subjects[index]['absent']++;
      }
    });
    _saveData();
  }

  void _deleteSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
    _saveData();
  }

  double _getPercentage(Map<String, dynamic> subject) {
    int total = subject['present'] + subject['absent'];
    if (total == 0) return 0;
    return (subject['present'] / total) * 100;
  }

  int _classesNeeded(Map<String, dynamic> subject) {
    int present = subject['present'];
    int total = subject['present'] + subject['absent'];
    int required = subject['required'];
    if (_getPercentage(subject) >= required) return 0;
    int needed = 0;
    while (((present + needed) / (total + needed)) * 100 < required) {
      needed++;
    }
    return needed;
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    int requiredPercent = 75;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setStateDialog) => Column(
                children: [
                  Text('Required: $requiredPercent%'),
                  Slider(
                    value: requiredPercent.toDouble(),
                    min: 50,
                    max: 100,
                    divisions: 10,
                    label: '$requiredPercent%',
                    onChanged: (val) {
                      setStateDialog(() {
                        requiredPercent = val.toInt();
                      });
                    },
                  ),
                ],
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
              if (nameController.text.isNotEmpty) {
                _addSubject(nameController.text, requiredPercent);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: subjects.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No subjects added yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first subject',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final percentage = _getPercentage(subject);
                final needed = _classesNeeded(subject);
                final isSafe = percentage >= subject['required'];
                final color = isSafe
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                subject['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deleteSubject(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${subject['present']}/${subject['present'] + subject['absent']})',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSafe
                              ? '✅ Safe to skip a few classes'
                              : '⚠️ Attend $needed more classes to reach ${subject['required']}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _markAttendance(index, true),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Present'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _markAttendance(index, false),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Absent'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
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