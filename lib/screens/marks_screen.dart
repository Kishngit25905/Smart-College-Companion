import 'package:flutter/material.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  final List<Map<String, dynamic>> subjects = [];
  final _subjectController = TextEditingController();
  final _internalController = TextEditingController();
  final _maxInternalController = TextEditingController();
  final _requiredTotalController = TextEditingController();

  void _addSubject() {
    if (_subjectController.text.isEmpty ||
        _internalController.text.isEmpty ||
        _maxInternalController.text.isEmpty ||
        _requiredTotalController.text.isEmpty) {
      return;
    }

    final internal = double.tryParse(_internalController.text) ?? 0;
    final maxInternal = double.tryParse(_maxInternalController.text) ?? 100;
    final requiredTotal = double.tryParse(_requiredTotalController.text) ?? 50;

    final externalNeeded = requiredTotal - internal;
    final percentage = (internal / maxInternal) * 100;

    setState(() {
      subjects.add({
        'name': _subjectController.text,
        'internal': internal,
        'maxInternal': maxInternal,
        'requiredTotal': requiredTotal,
        'externalNeeded': externalNeeded,
        'percentage': percentage,
      });
    });

    _subjectController.clear();
    _internalController.clear();
    _maxInternalController.clear();
    _requiredTotalController.clear();
  }

  void _deleteSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  Color _getStatusColor(Map<String, dynamic> subject) {
    if (subject['externalNeeded'] <= 0) return const Color(0xFF10B981);
    if (subject['externalNeeded'] <= 30) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getStatusText(Map<String, dynamic> subject) {
    if (subject['externalNeeded'] <= 0) return '🎉 Already passed!';
    if (subject['externalNeeded'] > 75) return '⚠️ Very high external marks needed';
    return '📝 Need ${subject['externalNeeded'].toStringAsFixed(1)} in external';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks Predictor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Internal Marks Predictor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your internal marks to predict how much you need in externals',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Subject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _internalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Your Internal Marks',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grade_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxInternalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Internal Marks',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bar_chart),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _requiredTotalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Required Total Marks (to pass)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.calculate),
                label: const Text('Predict'),
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
            const SizedBox(height: 24),
            if (subjects.isNotEmpty) ...[
              const Text(
                'Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...subjects.asMap().entries.map((entry) {
                final index = entry.key;
                final subject = entry.value;
                final color = _getStatusColor(subject);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subject['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteSubject(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Internal: ${subject['internal']}/${subject['maxInternal']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Internal %: ${subject['percentage'].toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Need\n${subject['externalNeeded'] <= 0 ? '0' : subject['externalNeeded'].toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(subject),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}