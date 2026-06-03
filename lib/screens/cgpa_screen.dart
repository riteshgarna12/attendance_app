// lib/screens/cgpa_screen.dart
import 'package:flutter/material.dart';
import '../models/semester.dart';
import '../utils/app_theme.dart';

class CGPAScreen extends StatelessWidget {
  final List<Semester> semesters;
  final ValueChanged<List<Semester>> onUpdate;

  const CGPAScreen(
      {super.key, required this.semesters, required this.onUpdate});

  double _cgpa() {
    double totalPoints = 0;
    double totalCredits = 0;
    for (var s in semesters) {
      for (var sub in s.subjects) {
        if (sub.grade != null) {
          totalPoints +=
              AppTheme.gradeToPoint(sub.grade!) * sub.credits;
          totalCredits += sub.credits;
        }
      }
    }
    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final cgpa = _cgpa();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPA Calculator',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  'Semester-wise SGPA & overall CGPA',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),

                // CGPA Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F6AF0), Color(0xFF00C9A7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Cumulative GPA (CGPA)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cgpa.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        _cgpaLabel(cgpa),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Grade bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (cgpa / 10).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('0',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const Text('5',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const Text('10',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Grade legend
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grade Scale',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppTheme.grades.map((g) {
                          final pts = AppTheme.gradeToPoint(g);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$g = $pts',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Semester-wise SGPA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        if (semesters.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'No semesters added yet.\nGo to Dashboard to add.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _SGPACard(semester: semesters[i]),
                childCount: semesters.length,
              ),
            ),
          ),
      ],
    );
  }

  String _cgpaLabel(double cgpa) {
    if (cgpa >= 9.5) return '🏆 Outstanding';
    if (cgpa >= 8.5) return '⭐ Excellent';
    if (cgpa >= 7.5) return '✅ Very Good';
    if (cgpa >= 6.5) return '👍 Good';
    if (cgpa >= 5.5) return '📘 Average';
    if (cgpa > 0) return '⚠️ Needs Improvement';
    return 'No Grades Added Yet';
  }
}

class _SGPACard extends StatelessWidget {
  final Semester semester;
  const _SGPACard({required this.semester});

  @override
  Widget build(BuildContext context) {
    final sgpa = semester.sgpa;
    final subjectsWithGrade =
        semester.subjects.where((s) => s.grade != null).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                semester.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sgpa > 0
                      ? AppTheme.primaryLight
                      : AppTheme.divider,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sgpa > 0 ? 'SGPA: ${sgpa.toStringAsFixed(2)}' : 'No Grades',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        sgpa > 0 ? AppTheme.primary : AppTheme.textLight,
                  ),
                ),
              ),
            ],
          ),
          if (subjectsWithGrade.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 8),
            ...subjectsWithGrade.map(
              (sub) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        sub.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${sub.credits} credits',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sub.grade} (${AppTheme.gradeToPoint(sub.grade!).toStringAsFixed(0)})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'No grades added yet. Go to subjects to add grades.',
              style:
                  TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
          if (sgpa > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (sgpa / 10).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppTheme.primaryLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
