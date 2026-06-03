// lib/models/semester.dart
import 'subject.dart';

class Semester {
  String id;
  String name;
  int semesterNumber;
  List<Subject> subjects;
  String collegeType; // engineering, medical, arts, commerce, science, law

  Semester({
    required this.id,
    required this.name,
    required this.semesterNumber,
    this.subjects = const [],
    this.collegeType = 'engineering',
  });

  double get sgpa {
    double totalWeightedPoints = 0;
    double totalCredits = 0;
    for (var sub in subjects) {
      if (sub.grade != null) {
        double gradePoint = _gradeToPoint(sub.grade!);
        totalWeightedPoints += gradePoint * sub.credits;
        totalCredits += sub.credits;
      }
    }
    if (totalCredits == 0) return 0;
    return totalWeightedPoints / totalCredits;
  }

  double get overallAttendance {
    if (subjects.isEmpty) return 0;
    int totalClasses = subjects.fold(0, (sum, s) => sum + s.totalClasses);
    int attendedClasses =
        subjects.fold(0, (sum, s) => sum + s.attendedClasses);
    if (totalClasses == 0) return 0;
    return (attendedClasses / totalClasses) * 100;
  }

  static double _gradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case 'O':
        return 10.0;
      case 'A+':
        return 9.0;
      case 'A':
        return 8.0;
      case 'B+':
        return 7.0;
      case 'B':
        return 6.0;
      case 'C':
        return 5.0;
      case 'D':
        return 4.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'semesterNumber': semesterNumber,
        'subjects': subjects.map((s) => s.toJson()).toList(),
        'collegeType': collegeType,
      };

  factory Semester.fromJson(Map<String, dynamic> json) => Semester(
        id: json['id'],
        name: json['name'],
        semesterNumber: json['semesterNumber'],
        subjects: (json['subjects'] as List<dynamic>? ?? [])
            .map((s) => Subject.fromJson(s))
            .toList(),
        collegeType: json['collegeType'] ?? 'engineering',
      );
}
