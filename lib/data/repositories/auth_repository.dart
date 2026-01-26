import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/student_profile.dart';
import '../models/mentor_profile.dart';


class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String domain,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: cred.user!.uid,
      email: email,
      name: name,
      domain: domain,
      role: role,
      verified: role == UserRole.student,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      studentProfile:
          role == UserRole.student ? StudentProfile(goals: '', xp: 0, badges: []) : null,
      mentorProfile:
          role == UserRole.mentor ? MentorProfile(experience: '', available: false, rating: 0) : null,
      adminProfile: null,
    );

    await _firestore
        .collection('users')
        .doc(cred.user!.uid)
        .set(user.toFirestore());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
