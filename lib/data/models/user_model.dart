import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_profile.dart';
import 'mentor_profile.dart';
import 'admin_profile.dart';

enum UserRole { student, mentor, admin }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String domain;
  final UserRole role;
  final bool verified;
  final DateTime createdAt;
  final DateTime lastLogin;

  final StudentProfile? studentProfile;
  final MentorProfile? mentorProfile;
  final AdminProfile? adminProfile;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.domain,
    required this.role,
    required this.verified,
    required this.createdAt,
    required this.lastLogin,
    this.studentProfile,
    this.mentorProfile,
    this.adminProfile,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'],
      name: data['name'],
      domain: data['domain'],
      role: UserRole.values.byName(data['role']),
      verified: data['verified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      studentProfile: data['studentProfile'] != null
          ? StudentProfile.fromMap(data['studentProfile'])
          : null,
      mentorProfile: data['mentorProfile'] != null
          ? MentorProfile.fromMap(data['mentorProfile'])
          : null,
      adminProfile: data['adminProfile'] != null
          ? AdminProfile.fromMap(data['adminProfile'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'domain': domain,
      'role': role.name,
      'verified': verified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      if (studentProfile != null) 'studentProfile': studentProfile!.toMap(),
      if (mentorProfile != null) 'mentorProfile': mentorProfile!.toMap(),
      if (adminProfile != null) 'adminProfile': adminProfile!.toMap(),
    };
  }
}
