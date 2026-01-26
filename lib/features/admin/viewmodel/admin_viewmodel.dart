import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';

class AdminViewModel {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> unverifiedMentorsStream() {
    return _usersRef
        .where('role', isEqualTo: 'mentor')
        .where('verified', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<void> approveMentor(String uid) async {
    await _usersRef.doc(uid).update({'verified': true});
  }
}
