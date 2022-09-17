import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart' as user;

import '../Constants.dart';

Future<DocumentSnapshot> getUserById(String userId) async {
  final db = FirebaseFirestore.instance;
  var userDocRef = db.collection(USERS_COLLECTION_KEY).doc(userId);
  return await userDocRef.get();
}

Future<DocumentSnapshot> getTreatmentById(String treatmentId) async {
  final db = FirebaseFirestore.instance;
  var userDocRef = db.collection(TREATMENTS_KEY).doc(treatmentId);
  return await userDocRef.get();
}

Future<String?> getUserIdByEmail(String? email) async {
  final db = FirebaseFirestore.instance;
  var future = await db
      .collection(USERS_COLLECTION_KEY)
      .where(EMAIL_KEY, isEqualTo: email ?? "")
      .limit(1)
      .get();
  if (future.docs.isEmpty) {
    return null;
  }
  return future.docs.first.id;
}

Future<bool> attachMedicoToPatient(
    String currentUserName,
    String currentEmail,
    String? emailUser,
    bool isPatient,
    Function errorFunction,
    Function successFunction) async {
  final db = FirebaseFirestore.instance;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) {
    return false;
  }
  String? userIdToVinculate = await getUserIdByEmail(emailUser);
  if (userIdToVinculate == null) {
    return false;
  }

  String patientId = isPatient ? currentUserId : userIdToVinculate;
  String medicoId = isPatient ? userIdToVinculate : currentUserId;

  await db
      .collection(PENDING_VINCULATIONS_COLLECTION_KEY)
      .add({
        VINCULATION_PENDING_EMAIL_KEY: currentEmail,
        VINCULATION_PENDING_NAME_KEY: currentUserName,
        VINCULATION_STATUS_KEY: VINCULATION_STATUS_PENDING,
        MEDICO_ID_KEY: medicoId,
        PATIENT_ID_KEY: patientId,
        APPLICANT_VINCULATION_USER_TYPE:
            (isPatient ? USER_TYPE_PACIENTE : USER_TYPE_MEDICO)
      })
      .then((value) => successFunction())
      .onError((error, stackTrace) => errorFunction());
  return true;
}
