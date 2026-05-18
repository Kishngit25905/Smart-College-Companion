import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_screen.dart';
import 'timetable_screen.dart';
import 'assignments_screen.dart';
import 'marks_screen.dart';
import 'notes_screen.dart';
import 'countdown_screen.dart';
import 'cgpa_screen.dart';
import 'chatbot_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String studentName = '';
  String studentDept = '';
  String studentSem = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studentName = prefs.getString('student_name') ?? 'Student';
      studentDept = prefs.getString('student_dept') ?? '';
      studentSem = prefs.getString('student_sem') ?? '';
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildBanner(),
              const SizedBox(height: 28),
              _buildSectionTitle('Your Tools', '8 modules'),
              const SizedBox(height: 16),
              _buildFeatureGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()} 👋',
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              studentName.isEmpty ? 'Smart Companion' : studentName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (studentDept.isNotEmpty)
              Text(
                '$studentDept · $studentSem',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              title: const Text('Logout?',
                  style: TextStyle(color: Colors.white)),
              content: const Text('This will clear your profile.',
                  style: TextStyle(color: Colors.grey)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                  child: const Text('Logout',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF6C63FF),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Track attendance daily to never fall below 75%!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
            ),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {
        'title': 'Attendance',
        'subtitle': 'Track your presence',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF10B981),
        'screen': const AttendanceScreen(),
      },
      {
        'title': 'Timetable',
        'subtitle': 'Plan your day',
        'icon': Icons.calendar_month_rounded,
        'color': const Color(0xFF3B82F6),
        'screen': const TimetableScreen(),
      },
      {
        'title': 'Assignments',
        'subtitle': 'Never miss deadlines',
        'icon': Icons.assignment_rounded,
        'color': const Color(0xFFF59E0B),
        'screen': const AssignmentsScreen(),
      },
      {
        'title': 'Marks',
        'subtitle': 'Predict your scores',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFFEF4444),
        'screen': const MarksScreen(),
      },
      {
        'title': 'Notes & PDFs',
        'subtitle': 'Organise resources',
        'icon': Icons.folder_rounded,
        'color': const Color(0xFF8B5CF6),
        'screen': const NotesScreen(),
      },
      {
        'title': 'Exam Timer',
        'subtitle': 'Countdown to exams',
        'icon': Icons.timer_rounded,
        'color': const Color(0xFFEC4899),
        'screen': const CountdownScreen(),
      },
      {
        'title': 'CGPA Calc',
        'subtitle': 'Calculate your GPA',
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFF06B6D4),
        'screen': const CgpaScreen(),
      },
      {
        'title': 'AI Chatbot',
        'subtitle': 'Ask any doubt',
        'icon': Icons.smart_toy_rounded,
        'color': const Color(0xFF6C63FF),
        'screen': const ChatbotScreen(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return _buildCard(
          title: f['title'] as String,
          subtitle: f['subtitle'] as String,
          icon: f['icon'] as IconData,
          color: f['color'] as Color,
          screen: f['screen'] as Widget,
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}