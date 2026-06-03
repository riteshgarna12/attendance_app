// lib/models/subject.dart

class Subject {
  String id;
  String name;
  int totalClasses;
  int attendedClasses;
  double credits;
  String? grade;

  Subject({
    required this.id,
    required this.name,
    this.totalClasses = 0,
    this.attendedClasses = 0,
    this.credits = 3.0,
    this.grade,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (attendedClasses / totalClasses) * 100;
  }

  bool get isSafe => attendancePercentage >= 75;
  bool get isWarning =>
      attendancePercentage >= 65 && attendancePercentage < 75;
  bool get isDanger => attendancePercentage < 65;

  /// How many more classes needed to reach [targetPercent]
  int classesNeededForTarget(double targetPercent) {
    if (attendancePercentage >= targetPercent) return 0;
    // (attended + x) / (total + x) = target/100
    // attended + x = target/100 * total + target/100 * x
    // x * (1 - target/100) = target/100 * total - attended
    double t = targetPercent / 100;
    double needed = (t * totalClasses - attendedClasses) / (1 - t);
    return needed.ceil().clamp(0, 9999);
  }

  /// How many classes can be skipped while keeping attendance >= [targetPercent]
  int classesCanSkip(double targetPercent) {
    // (attended) / (total + x) >= target/100
    // attended * 100 >= target * (total + x)
    // x <= (attended*100 - target*total) / target
    double canSkip =
        (attendedClasses * 100 - targetPercent * totalClasses) / targetPercent;
    return canSkip.floor().clamp(0, 9999);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalClasses': totalClasses,
        'attendedClasses': attendedClasses,
        'credits': credits,
        'grade': grade,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        name: json['name'],
        totalClasses: json['totalClasses'] ?? 0,
        attendedClasses: json['attendedClasses'] ?? 0,
        credits: (json['credits'] ?? 3.0).toDouble(),
        grade: json['grade'],
      );
}
