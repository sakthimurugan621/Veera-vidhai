import 'package:flutter/foundation.dart';

/// Holds the admin's currently-selected team. Every admin screen reads this
/// so switching teams instantly re-scopes all data (students, attendance,
/// fees, leave) to that team.
class TeamProvider extends ChangeNotifier {
  String? _activeTeamId;
  String _activeTeamName = '';

  String? get activeTeamId => _activeTeamId;
  String get activeTeamName => _activeTeamName;
  bool get hasTeam => _activeTeamId != null;

  void setActive(String id, String name) {
    _activeTeamId = id;
    _activeTeamName = name;
    notifyListeners();
  }

  void clear() {
    _activeTeamId = null;
    _activeTeamName = '';
    notifyListeners();
  }
}
