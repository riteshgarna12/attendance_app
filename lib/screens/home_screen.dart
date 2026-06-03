// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/semester.dart';
import '../utils/app_theme.dart';
import '../utils/storage_helper.dart';
import '../widgets/attendance_meter.dart';
import 'semester_detail_screen.dart';
import 'cgpa_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Semester> _semesters = [];
  String _studentName = 'Student';
  String _collegeType = 'Engineering';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final semesters = await StorageHelper.loadSemesters();
    final name = await StorageHelper.getStudentName();
    final type = await StorageHelper.getCollegeType();
    if (mounted) {
      setState(() {
        _semesters = semesters;
        _studentName = name;
        _collegeType = type;
      });
    }
  }

  Future<void> _save() async {
    await StorageHelper.saveSemesters(_semesters);
  }

  double get _overallAttendance {
    if (_semesters.isEmpty) return 0;
    int total = 0, attended = 0;
    for (final s in _semesters) {
      for (final sub in s.subjects) {
        total += sub.totalClasses;
        attended += sub.attendedClasses;
      }
    }
    if (total == 0) return 0;
    return (attended / total) * 100;
  }

  double get _cgpa {
    if (_semesters.isEmpty) return 0;
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in _semesters) {
      for (final sub in s.subjects) {
        if (sub.grade != null) {
          totalPoints += AppTheme.gradeToPoint(sub.grade!) * sub.credits;
          totalCredits += sub.credits;
        }
      }
    }
    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  Future<void> _addSemester() async {
    final nameCtrl = TextEditingController(
        text: 'Semester ${_semesters.length + 1}');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Semester',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Semester Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();

    if (result != null && result.isNotEmpty) {
      setState(() {
        _semesters.add(Semester(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result,
          semesterNumber: _semesters.length + 1,
          collegeType: _collegeType,
        ));
      });
      await _save();
    }
  }

  Future<void> _deleteSemester(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Semester',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Delete "${_semesters[index].name}"? This will remove all subjects.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _semesters.removeAt(index));
      await _save();
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $_studentName 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '$_collegeType Student',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()));
                          _loadData();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.settings_outlined,
                              color: AppTheme.primary, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Overall Attendance Meter
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F6AF0), Color(0xFF6C63FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(79, 106, 240, 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Overall Attendance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: _OverallMeter(percentage: _overallAttendance),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatChip(
                              label: 'CGPA',
                              value: _cgpa.toStringAsFixed(2),
                              icon: Icons.school_outlined,
                            ),
                            _StatChip(
                              label: 'Semesters',
                              value: '${_semesters.length}',
                              icon: Icons.calendar_today_outlined,
                            ),
                            _StatChip(
                              label: 'Subjects',
                              value:
                                  '${_semesters.fold(0, (sum, s) => sum + s.subjects.length)}',
                              icon: Icons.book_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Semesters header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Semesters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _addSemester,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: AppTheme.primary, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Add',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Semester cards
          if (_semesters.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 64, color: AppTheme.textLight),
                    SizedBox(height: 16),
                    Text(
                      'No semesters yet',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap "Add" to create your first semester',
                      style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _SemesterCard(
                    semester: _semesters[i],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SemesterDetailScreen(
                            semester: _semesters[i],
                            onUpdate: (updated) {
                              setState(() => _semesters[i] = updated);
                              _save();
                            },
                          ),
                        ),
                      );
                      _loadData();
                    },
                    onDelete: () => _deleteSemester(i),
                  ),
                  childCount: _semesters.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      CGPAScreen(
        semesters: _semesters,
        onUpdate: (updated) {
          setState(() => _semesters = updated);
          _save();
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Dashboard',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'GPA',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── _OverallMeter ────────────────────────────────────────────────────────────

class _OverallMeter extends StatelessWidget {
  final double percentage;
  const _OverallMeter({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return AttendanceMeter(
      percentage: percentage,
      size: 160,
      showLabel: true,
    );
  }
}

// ─── _StatChip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _SemesterCard ────────────────────────────────────────────────────────────

class _SemesterCard extends StatelessWidget {
  final Semester semester;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SemesterCard({
    required this.semester,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final attendance = semester.overallAttendance;
    final sgpa = semester.sgpa;
    final Color statusColor = attendance >= 75
        ? AppTheme.success
        : attendance >= 65
            ? AppTheme.warning
            : AppTheme.danger;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: AttendanceMeter(
                percentage: attendance,
                size: 64,
                showLabel: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    semester.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${semester.subjects.length} subjects',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Pill(
                          label:
                              '${attendance.toStringAsFixed(1)}% Attendance',
                          color: statusColor),
                      const SizedBox(width: 6),
                      if (sgpa > 0)
                        _Pill(
                            label: 'SGPA: ${sgpa.toStringAsFixed(2)}',
                            color: AppTheme.primary),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.chevron_right, color: AppTheme.textLight),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      color: AppTheme.danger, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _Pill ────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── _NavItem ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primary : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.primary : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}