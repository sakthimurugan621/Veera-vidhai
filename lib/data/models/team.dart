import 'package:cloud_firestore/cloud_firestore.dart';

/// A team (batch) in the academy. Students belong to a team; the admin
/// switches between teams to view that team's data.
class Team {
  final String id;
  final String name;
  final int order;

  const Team({required this.id, required this.name, this.order = 0});

  factory Team.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Team(
      id: doc.id,
      name: d['name'] ?? doc.id,
      order: (d['order'] ?? 0) as int,
    );
  }
}
