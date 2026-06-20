import 'package:cloud_firestore/cloud_firestore.dart';

/// A student record stored in Firestore `students` collection.
/// Created by the admin; the student logs in with phone + password.
class AppStudent {
  final String id;
  final String name;
  final String rollNo;
  final String phone;
  final String password;
  final String className;
  final String address;
  final double feeAmount; // monthly fee
  final String feeStatus; // 'paid' | 'unpaid'
  final String lastPaidDate; // 'dd MMM yyyy' or ''
  final DateTime? createdAt;

  const AppStudent({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.phone,
    required this.password,
    this.className = 'Silambam Beginner',
    this.address = '',
    this.feeAmount = 500,
    this.feeStatus = 'unpaid',
    this.lastPaidDate = '',
    this.createdAt,
  });

  bool get feesPaid => feeStatus == 'paid';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  factory AppStudent.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppStudent(
      id: doc.id,
      name: d['name'] ?? '',
      rollNo: d['rollNo'] ?? '',
      phone: d['phone'] ?? '',
      password: d['password'] ?? '',
      className: d['className'] ?? 'Silambam Beginner',
      address: d['address'] ?? '',
      feeAmount: (d['feeAmount'] ?? 500).toDouble(),
      feeStatus: d['feeStatus'] ?? 'unpaid',
      lastPaidDate: d['lastPaidDate'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rollNo': rollNo,
      'phone': phone,
      'password': password,
      'className': className,
      'address': address,
      'feeAmount': feeAmount,
      'feeStatus': feeStatus,
      'lastPaidDate': lastPaidDate,
    };
  }

  AppStudent copyWith({
    String? name,
    String? rollNo,
    String? phone,
    String? password,
    String? className,
    String? address,
    double? feeAmount,
    String? feeStatus,
    String? lastPaidDate,
  }) {
    return AppStudent(
      id: id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      className: className ?? this.className,
      address: address ?? this.address,
      feeAmount: feeAmount ?? this.feeAmount,
      feeStatus: feeStatus ?? this.feeStatus,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      createdAt: createdAt,
    );
  }
}
