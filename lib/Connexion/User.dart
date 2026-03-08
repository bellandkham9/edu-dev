import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String? avatar;
  final String? status;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.avatar,
    required this.status,
  });

  // 🔹 Convertir AppUser en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'avatar': avatar,
      'status': status,
    };
  }

  // 🔹 Créer un AppUser à partir d'un document Firestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? '',
      avatar: data['avatar'],
      status: data['status'] ?? '',
    );
  }

  // 🔹 Créer un AppUser à partir d'une Map (ex: JSON ou autre)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      avatar: map['avatar'],
      status: map['status'] ?? '',
    );
  }
}
