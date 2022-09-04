import 'package:cloud_firestore/cloud_firestore.dart';

import '../Constants.dart';

Future<DocumentSnapshot> getUserById(String userId) async {
  final db = FirebaseFirestore.instance;
  var userDocRef = db
      .collection(USERS_COLLECTION_KEY)
      .doc(userId);
  return await userDocRef.get();
}