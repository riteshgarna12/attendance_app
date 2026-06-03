// lib/utils/storage_helper.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/semester.dart';

class StorageHelper {
  static const String _semestersKey = 'semesters';
  static const String _collegeTypeKey = 'collegeType';
  static const String _studentNameKey = 'studentName';

  static Future<List<Semester>> loadSemesters() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_semestersKey);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Semester.fromJson(e)).toList();
  }

  static Future<void> saveSemesters(List<Semester> semesters) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(semesters.map((s) => s.toJson()).toList());
    await prefs.setString(_semestersKey, data);
  }

  static Future<String> getCollegeType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_collegeTypeKey) ?? 'Engineering';
  }

  static Future<void> setCollegeType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_collegeTypeKey, type);
  }

  static Future<String> getStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_studentNameKey) ?? 'Student';
  }

  static Future<void> setStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentNameKey, name);
  }
}
