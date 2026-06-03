// lib/widgets/subject_card.dart
import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../utils/app_theme.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final double targetAttendance;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onDelete,
    this.targetAttendance = 75,
  });

  @override
  Widget build(BuildContext context) {
    final pct = subject.attendancePercentage;
    final Color statusColor = subject.isSafe
        ? AppTheme.success
        : subject.isWarning
            ? AppTheme.warning
            : AppTheme.danger;

    final Color statusBg = subject.isSafe
        ? AppTheme.successLight
        : subject.isWarning
            ? AppTheme.warningLight
            : AppTheme.dangerLight;

    String statusMsg;
    if (subject.isSafe) {
      final canSkip = subject.classesCanSkip(targetAttendance);
      statusMsg = canSkip > 0 ? 'Can skip $canSkip class(es)' : 'On the edge';
    } else if (subject.isWarning) {
      final need = subject.classesNeededForTarget(targetAttendance);
      statusMsg = 'Attend $need more class(es)';
    } else {
      final need = subject.classesNeededForTarget(targetAttendance);
      statusMsg = 'Need $need more class(es)!';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(statusColor.red, statusColor.green, statusColor.blue, 0.06),
              blurRadius: 12,
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subject.attendedClasses}/${subject.totalClasses} classes  •  ${subject.credits} credits',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppTheme.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Color.fromRGBO(statusColor.red, statusColor.green, statusColor.blue, 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusMsg,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (subject.grade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Grade: ${subject.grade}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
