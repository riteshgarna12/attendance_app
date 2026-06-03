// lib/screens/semester_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/semester.dart';
import '../models/subject.dart';
import '../utils/app_theme.dart';
import '../widgets/attendance_meter.dart';
import '../widgets/subject_card.dart';
import 'subject_detail_screen.dart';

class SemesterDetailScreen extends StatefulWidget {
  final Semester semester;
  final ValueChanged<Semester> onUpdate;

  const SemesterDetailScreen({
    super.key,
    required this.semester,
    required this.onUpdate,
  });

  @override
  State<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends State<SemesterDetailScreen> {
  late Semester _semester;
  double _targetAttendance = 75;

  @override
  void initState() {
    super.initState();
    _semester = widget.semester;
  }

  void _update(Semester updated) {
    setState(() => _semester = updated);
    widget.onUpdate(updated);
  }

  void _addSubject() async {
    final nameCtrl = TextEditingController();
    final creditsCtrl = TextEditingController(text: '3');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Subject',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Subject Name'),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsCtrl,
                decoration: const InputDecoration(labelText: 'Credits'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,1}'))
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, {
                    'name': nameCtrl.text.trim(),
                    'credits': double.tryParse(creditsCtrl.text) ?? 3.0,
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final updated = Semester(
        id: _semester.id,
        name: _semester.name,
        semesterNumber: _semester.semesterNumber,
        collegeType: _semester.collegeType,
        subjects: [
          ..._semester.subjects,
          Subject(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: result['name'],
            credits: result['credits'],
          ),
        ],
      );
      _update(updated);
    }
  }

  void _deleteSubject(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Subject'),
        content: Text('Delete "${_semester.subjects[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final newSubjects = List<Subject>.from(_semester.subjects)
        ..removeAt(index);
      _update(Semester(
        id: _semester.id,
        name: _semester.name,
        semesterNumber: _semester.semesterNumber,
        collegeType: _semester.collegeType,
        subjects: newSubjects,
      ));
    }
  }

  Widget _buildStatsRow() {
    int safeCount = _semester.subjects.where((s) => s.isSafe).length;
    int warnCount = _semester.subjects.where((s) => s.isWarning).length;
    int dangerCount = _semester.subjects.where((s) => s.isDanger).length;

    return Row(
      children: [
        _StatsBox(
            count: safeCount,
            label: 'Safe',
            color: AppTheme.success,
            bg: AppTheme.successLight),
        const SizedBox(width: 10),
        _StatsBox(
            count: warnCount,
            label: 'Warning',
            color: AppTheme.warning,
            bg: AppTheme.warningLight),
        const SizedBox(width: 10),
        _StatsBox(
            count: dangerCount,
            label: 'Danger',
            color: AppTheme.danger,
            bg: AppTheme.dangerLight),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final overall = _semester.overallAttendance;
    final sgpa = _semester.sgpa;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_semester.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppTheme.primary),
            onPressed: _addSubject,
            tooltip: 'Add Subject',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Semester Overview Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0,0,0,0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AttendanceMeter(
                            percentage: overall, size: 120),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Semester Overview',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (sgpa > 0) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.school_outlined,
                                        size: 16,
                                        color: AppTheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SGPA: ${sgpa.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              _buildStatsRow(),
                              const SizedBox(height: 12),
                              // Target slider
                              Row(
                                children: [
                                  const Text('Target: ',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary)),
                                  Text(
                                    '${_targetAttendance.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                  trackHeight: 4,
                                  activeTrackColor: AppTheme.primary,
                                  inactiveTrackColor: AppTheme.border,
                                  thumbColor: AppTheme.primary,
                                ),
                                child: Slider(
                                  value: _targetAttendance,
                                  min: 60,
                                  max: 100,
                                  divisions: 40,
                                  onChanged: (v) =>
                                      setState(() => _targetAttendance = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Subjects header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subjects (${_semester.subjects.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _addSubject,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add,
                                  color: AppTheme.primary, size: 14),
                              SizedBox(width: 4),
                              Text('Add Subject',
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
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

          // Subject cards
          if (_semester.subjects.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.book_outlined,
                        size: 56, color: AppTheme.textLight),
                    const SizedBox(height: 12),
                    const Text('No subjects yet',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    const Text('Tap "Add Subject" to get started',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textLight)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final subject = _semester.subjects[i];
                    return SubjectCard(
                      subject: subject,
                      targetAttendance: _targetAttendance,
                      onDelete: () => _deleteSubject(i),
                      onTap: () async {
                        final updated =
                            await Navigator.push<Subject>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubjectDetailScreen(
                              subject: subject,
                            ),
                          ),
                        );
                        if (updated != null) {
                          final newSubjects =
                              List<Subject>.from(_semester.subjects);
                          newSubjects[i] = updated;
                          _update(Semester(
                            id: _semester.id,
                            name: _semester.name,
                            semesterNumber: _semester.semesterNumber,
                            collegeType: _semester.collegeType,
                            subjects: newSubjects,
                          ));
                        }
                      },
                    );
                  },
                  childCount: _semester.subjects.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsBox extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bg;

  const _StatsBox(
      {required this.count,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(color.red,color.green,color.blue,0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
