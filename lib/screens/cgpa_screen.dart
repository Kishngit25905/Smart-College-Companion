import 'package:flutter/material.dart';

class CgpaScreen extends StatefulWidget {
  const CgpaScreen({super.key});

  @override
  State<CgpaScreen> createState() => _CgpaScreenState();
}

class _CgpaScreenState extends State<CgpaScreen> {
  List<Map<String, dynamic>> semesters = [];
  double cgpa = 0.0;

  final gradePoints = {
    'O': 10.0,
    'A+': 9.0,
    'A': 8.0,
    'B+': 7.0,
    'B': 6.0,
    'C': 5.0,
    'F': 0.0,
  };

  void _addSemester() {
    setState(() {
      semesters.add({
        'name': 'Semester ${semesters.length + 1}',
        'subjects': <Map<String, dynamic>>[],
        'gpa': 0.0,
      });
    });
  }

  void _addSubject(int semIndex) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final creditsController = TextEditingController();
        String selectedGrade = 'O';

        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Add Subject'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Credits',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grade_outlined),
                  ),
                  items: gradePoints.keys
                      .map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text('$grade (${gradePoints[grade]})'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setStateDialog(() {
                      selectedGrade = val!;
                    });
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
                      creditsController.text.isNotEmpty) {
                    final credits =
                        int.tryParse(creditsController.text) ?? 0;
                    setState(() {
                      semesters[semIndex]['subjects'].add({
                        'name': nameController.text,
                        'credits': credits,
                        'grade': selectedGrade,
                        'gradePoint': gradePoints[selectedGrade],
                      });
                      _calculateGPA(semIndex);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculateGPA(int semIndex) {
    final subjects =
        semesters[semIndex]['subjects'] as List<Map<String, dynamic>>;
    if (subjects.isEmpty) return;

    double totalPoints = 0;
    int totalCredits = 0;

    for (var subject in subjects) {
      totalPoints += subject['gradePoint'] * subject['credits'];
      totalCredits += subject['credits'] as int;
    }

    setState(() {
      semesters[semIndex]['gpa'] =
          totalCredits > 0 ? totalPoints / totalCredits : 0.0;
      _calculateCGPA();
    });
  }

  void _calculateCGPA() {
    if (semesters.isEmpty) return;
    double total = 0;
    for (var sem in semesters) {
      total += sem['gpa'] as double;
    }
    setState(() {
      cgpa = total / semesters.length;
    });
  }

  void _deleteSubject(int semIndex, int subIndex) {
    setState(() {
      semesters[semIndex]['subjects'].removeAt(subIndex);
      _calculateGPA(semIndex);
    });
  }

  void _deleteSemester(int index) {
    setState(() {
      semesters.removeAt(index);
      _calculateCGPA();
    });
  }

  Color _cgpaColor(double value) {
    if (value >= 8.5) return const Color(0xFF10B981);
    if (value >= 7.0) return const Color(0xFF3B82F6);
    if (value >= 5.0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _cgpaGrade(double value) {
    if (value >= 9.0) return 'Outstanding 🏆';
    if (value >= 8.0) return 'Excellent 🌟';
    if (value >= 7.0) return 'Very Good 👍';
    if (value >= 6.0) return 'Good 😊';
    if (value >= 5.0) return 'Average 📚';
    return 'Need Improvement 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA Calculator'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSemester,
        icon: const Icon(Icons.add),
        label: const Text('Add Semester'),
        backgroundColor: const Color(0xFF06B6D4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your CGPA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cgpa.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _cgpaGrade(cgpa),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatBox(
                          '${semesters.length}', 'Semesters'),
                      const SizedBox(width: 16),
                      _buildStatBox(
                        '${semesters.fold(0, (sum, sem) => sum + (sem['subjects'] as List).length)}',
                        'Subjects',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (semesters.isEmpty)
              const Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Icon(Icons.calculate_outlined,
                        size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No semesters added yet!',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add your first semester',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ...semesters.asMap().entries.map((entry) {
              final semIndex = entry.key;
              final sem = entry.value;
              final subjects =
                  sem['subjects'] as List<Map<String, dynamic>>;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sem['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _cgpaColor(sem['gpa'])
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'GPA: ${(sem['gpa'] as double).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: _cgpaColor(sem['gpa']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteSemester(semIndex),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (subjects.isNotEmpty)
                      ...subjects.asMap().entries.map((subEntry) {
                        final subIndex = subEntry.key;
                        final subject = subEntry.value;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _cgpaColor(subject['gradePoint'])
                                    .withOpacity(0.1),
                            child: Text(
                              subject['grade'],
                              style: TextStyle(
                                color: _cgpaColor(
                                    subject['gradePoint']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(subject['name']),
                          subtitle: Text(
                              '${subject['credits']} credits · ${subject['gradePoint']} points'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.red, size: 20),
                            onPressed: () =>
                                _deleteSubject(semIndex, subIndex),
                          ),
                        );
                      }),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: OutlinedButton.icon(
                        onPressed: () => _addSubject(semIndex),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Subject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF06B6D4),
                          side: const BorderSide(
                              color: Color(0xFF06B6D4)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}