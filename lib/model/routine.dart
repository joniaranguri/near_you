import 'package:cloud_firestore/cloud_firestore.dart';

import '../Constants.dart';

class Routine {
  Routine(
      {
      required this.treatmentId,
      required this.medicationPercentage,
      required this.activityPercentage,
      required this.nutritionPercentage,
      required this.examsPercentage,
      required this.totalPercentage});

  String? treatmentId;
  String? medicationPercentage;
  String? databaseId;
  String? activityPercentage;
  String? nutritionPercentage;
  String? examsPercentage;
  String? totalPercentage;

  factory Routine.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return Routine(
        treatmentId: realData[TREATMENT_ID_KEY],
        medicationPercentage: realData[ROUTINE_MEDICATION_PERCENTAGE_KEY],
        nutritionPercentage: realData[ROUTINE_NUTRITION_PERCENTAGE_KEY],
        activityPercentage: realData[ROUTINE_ACTIVITY_PERCENTAGE_KEY],
        examsPercentage: realData[ROUTINE_EXAMS_PERCENTAGE_KEY],
        totalPercentage: realData[ROUTINE_TOTAL_PERCENTAGE_KEY]);
  }
}
