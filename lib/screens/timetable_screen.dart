import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  String selectedDay = 'Mon';
  Map<String, List<Map<String, String>>> timetable = {};

  @override
  void initState() {
    super.initState();
    for (var day in days) {
      timetable[day] = [];
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('timetable');
    if (data != null) {
      final Map<String, dynamic> decoded = jsonDecode(data);
      setState(() {
        decoded.forEach((key, value) {
          timetable[key] = List<Map<String, String>>.from(
            (value as List).map((e) => Map<String, String>.from(e)),
          );
        });
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timetable', jsonEncode(timetable));
  }

  void _addClass(String subject, String time, String room) {
    setState(() {
      timetable[selectedDay]!.add({
        'subject': subject,
        'time': time,
        'room': room,
      });
      timetable[selectedDay]!.sort((a, b) => a['time']!.compareTo(b['time']!));
    });
    _saveData();
  }

  void _deleteClass(int index) {
    setState(() {
      timetable[selectedDay]!.removeAt(index);
    });
    _saveData();
  }

  void _showAddClassDialog() {
    final subjectController = TextEditingController();
    final roomController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: 'Room / Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.room_outlined),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('Time: ${selectedTime.format(context)}'),
                trailing: const Icon(Icons.edit),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setStateDialog(() {
                      selectedTime = picked;
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
                if (subjectController.text.isNotEmpty) {
                  _addClass(
                    subjectController.text,
                    selectedTime.format(context),
                    roomController.text.isEmpty ? 'TBD' : roomController.text,
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
    final todayClasses = timetable[selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClassDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: days.map((day) {
                  final isSelected = day == selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = day),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: todayClasses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No classes today!',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + to add a class',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: todayClasses.length,
                    itemBuilder: (context, index) {
                      final cls = todayClasses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.book_outlined,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          title: Text(
                            cls['subject']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(cls['time']!,
                                  style:
                                      const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 12),
                              const Icon(Icons.room_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(cls['room']!,
                                  style:
                                      const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _deleteClass(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}