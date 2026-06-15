import 'package:flutter/foundation.dart';
import '../data/models/student_model.dart';
import '../data/dummy_data.dart';

class AuthProvider extends ChangeNotifier {
  Student? _currentStudent;
  bool _isAdmin = false;
  bool _isLoggedIn = false;

  Student? get currentStudent => _currentStudent;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;

  bool loginAsAdmin(String email, String password) {
    if (password == DummyData.adminPassword) {
      _isAdmin = true;
      _isLoggedIn = true;
      _currentStudent = null;
      DummyData.isAdmin = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool loginAsStudent(String rollNo, String password) {
    if (password != DummyData.studentPassword) return false;

    final student = DummyData.students.where((s) => s.rollNo == rollNo).firstOrNull;
    if (student == null) return false;

    _currentStudent = student;
    _isAdmin = false;
    _isLoggedIn = true;
    DummyData.loggedInStudent = student;
    DummyData.isAdmin = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentStudent = null;
    _isAdmin = false;
    _isLoggedIn = false;
    DummyData.loggedInStudent = null;
    DummyData.isAdmin = false;
    notifyListeners();
  }
}
