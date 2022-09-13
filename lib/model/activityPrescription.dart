import '../Constants.dart';

class ActivityPrescription {
  String? databaseId;
  int state = 0;
  String? name;
  String? activity;
  String? periodicity;
  String? calories;
  String? timeNumber;
  String? timeType;
  String? treatmentId;
  String? permitted;

  ActivityPrescription(
      {required this.databaseId,
      required this.treatmentId,
      required this.name,
      required this.activity,
      required this.timeNumber,
      required this.timeType,
      required this.periodicity,
      required this.calories,
      required this.permitted});

  factory ActivityPrescription.empty() {
    return ActivityPrescription(
        databaseId: "",
        treatmentId: "",
        name: "",
        activity: "",
        timeNumber: "",
        timeType: "",
        periodicity: "",
        calories: "",
        permitted: "");
  }

  factory ActivityPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return ActivityPrescription(
        databaseId: snapshot.id,
        treatmentId: realData[TREATMENT_ID_KEY],
        name: realData[ACTIVITY_NAME_KEY],
        activity: realData[ACTIVITY_ACTIVITY_KEY],
        timeNumber: realData[ACTIVITY_TIME_NUMBER_KEY],
        timeType: realData[ACTIVITY_TIME_TYPE_KEY],
        periodicity: realData[ACTIVITY_PERIODICITY_KEY],
        calories: realData[ACTIVITY_CALORIES_KEY],
        permitted: realData[PERMITTED_KEY]);
  }
}
