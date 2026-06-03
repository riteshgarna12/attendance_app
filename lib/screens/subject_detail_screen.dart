// lib/screens/subject_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import '../utils/app_theme.dart';
import '../widgets/attendance_meter.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  late Subject _subject;
  final _totalCtrl = TextEditingController();
  final _attendedCtrl = TextEditingController();
  String? _selectedGrade;

  @override
  void initState() {
    super.initState();
    _subject = widget.subject;
    _totalCtrl.text = _subject.totalClasses.toString();
    _attendedCtrl.text = _subject.attendedClasses.toString();
    _selectedGrade = _subject.grade;
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _attendedCtrl.dispose();
    super.dispose();
  }

  void _update() {
    final total = int.tryParse(_totalCtrl.text) ?? _subject.totalClasses;
    final attended = int.tryParse(_attendedCtrl.text) ?? _subject.attendedClasses;
    setState(() {
      _subject = Subject(
        id: _subject.id,
        name: _subject.name,
        credits: _subject.credits,
        totalClasses: total,
        attendedClasses: attended.clamp(0, total),
        grade: _selectedGrade,
      );
      _attendedCtrl.text = _subject.attendedClasses.toString();
    });
  }

  void _markAttendance(bool present) {
    setState(() {
      _subject = Subject(
        id: _subject.id,
        name: _subject.name,
        credits: _subject.credits,
        totalClasses: _subject.totalClasses + 1,
        attendedClasses: _subject.attendedClasses + (present ? 1 : 0),
        grade: _selectedGrade,
      );
      _totalCtrl.text = _subject.totalClasses.toString();
      _attendedCtrl.text = _subject.attendedClasses.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pct = _subject.attendancePercentage;
    final Color statusColor = _subject.isSafe
        ? AppTheme.success
        : _subject.isWarning
            ? AppTheme.warning
            : AppTheme.danger;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context, _subject),
        ),
        title: Text(_subject.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _subject),
            child: const Text('Save',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meter Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(statusColor.red, statusColor.green, statusColor.blue, 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Center(child: AttendanceMeter(percentage: pct, size: 200)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _InfoPill(label: 'Attended', value: '${_subject.attendedClasses}', color: AppTheme.primary),
                      _InfoPill(label: 'Total', value: '${_subject.totalClasses}', color: AppTheme.textSecondary),
                      _InfoPill(label: 'Absent',
                          value: '${_subject.totalClasses - _subject.attendedClasses}',
                          color: AppTheme.danger),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(statusColor.red, statusColor.green, statusColor.blue, 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Color.fromRGBO(statusColor.red, statusColor.green, statusColor.blue, 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _subject.isSafe
                            ? Icons.check_circle_outline
                            : _subject.isWarning
                                ? Icons.warning_amber_outlined
                                : Icons.cancel_outlined,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _subject.isSafe
                            ? 'You\'re Safe!'
                            : _subject.isWarning
                                ? 'Warning Zone'
                                : 'Detention Risk!',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: statusColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_subject.isSafe)
                    Text(
                      'You can skip ${_subject.classesCanSkip(75)} more class(es) and still remain safe (≥75%)',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(statusColor.red, statusColor.green, statusColor.blue, 0.8)),
                    )
                  else
                    Text(
                      'You need to attend ${_subject.classesNeededForTarget(75)} more class(es) to reach 75% attendance',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(statusColor.red, statusColor.green, statusColor.blue, 0.8)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Mark
            const Text('Mark Today\'s Class',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _markAttendance(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Color.fromRGBO(AppTheme.success.red, AppTheme.success.green, AppTheme.success.blue, 0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: AppTheme.success, size: 28),
                          SizedBox(height: 6),
                          Text('Present',
                              style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _markAttendance(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Color.fromRGBO(AppTheme.danger.red, AppTheme.danger.green, AppTheme.danger.blue, 0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.cancel_outlined, color: AppTheme.danger, size: 28),
                          SizedBox(height: 6),
                          Text('Absent',
                              style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Manual Entry
            const Text('Update Manually',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _totalCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Total Classes',
                      prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.primary, size: 18),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _update(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _attendedCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Attended',
                      prefixIcon: Icon(Icons.how_to_reg_outlined, color: AppTheme.success, size: 18),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _update(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grade selector
            const Text('Grade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppTheme.grades.map((g) {
                final isSelected = _selectedGrade == g;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGrade = isSelected ? null : g;
                      _subject = Subject(
                        id: _subject.id,
                        name: _subject.name,
                        credits: _subject.credits,
                        totalClasses: _subject.totalClasses,
                        attendedClasses: _subject.attendedClasses,
                        grade: _selectedGrade,
                      );
                    });
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border),
                    ),
                    child: Center(
                      child: Text(
                        g,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _subject),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
