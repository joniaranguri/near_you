import 'package:cloud_firestore/cloud_firestore.dart';

import '../Constants.dart';

class User {
  User(
      {required this.fullName,
      required this.email,
      required this.userId,
      required this.birthDay,
      required this.phone,
      required this.address,
      required this.age,
      required this.type,
      required this.allergies,
      required this.smoking,
      required this.alternativePhone,
      required this.reference,
      required this.gender,
      required this.medicalCenter,
      required this.illness,
      required this.attachedPatients,
      required this.adherenceLevel});

  String? attachedPatients;
  String? fullName;
  String? userId;
  String? email;
  String? adherenceLevel;
  String? birthDay;
  String? phone;

  String? age;

  String? address;

  String? medicalCenter;

  String? gender;

  String? reference;

  String? alternativePhone;

  String? smoking;

  String? allergies;

  String? type;
  String? illness;

  factory User.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return User(
        fullName: realData[FULL_NAME_KEY],
        email: realData[EMAIL_KEY],
        userId: realData[USER_ID_KEY],
        birthDay: realData[BIRTH_DAY_KEY],
        phone: realData[PHONE_KEY],
        age: realData[AGE_KEY],
        address: realData[ADDRESS_KEY],
        medicalCenter: realData[MEDICAL_CENTER_VALUE],
        gender: realData[GENDER_KEY],
        reference: realData[REFERENCE_KEY],
        alternativePhone: realData[ALT_PHONE_NUMBER_KEY],
        smoking: realData[SMOKING_KEY],
        allergies: realData[ALLERGIES_KEY],
        type: realData[USER_TYPE],
        illness: realData[USER_ILLNESS],
        attachedPatients: realData[ATTACHED_PATIENTS],
        adherenceLevel: realData[ADHERENCE_LEVEL_KEY]
    );
  }

  bool isPatiente() {
    return type == USER_TYPE_PACIENTE;
  }
}
