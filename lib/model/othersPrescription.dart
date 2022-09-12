import '../Constants.dart';

class OthersPrescription {
  String? treatmentId;
  String? name;
  String? duration;
  String? periodicity;
  String? detail;
  String? recommendation;

  OthersPrescription(
      {required this.treatmentId,
      required this.name,
      required this.duration,
      required this.periodicity,
      required this.detail,
      required this.recommendation});

  factory OthersPrescription.empty() {
    return OthersPrescription(
        treatmentId: "",
        name: "",
        duration: "",
        periodicity: "",
        detail: "",
        recommendation: "");
  }

  factory OthersPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return OthersPrescription(
        treatmentId: realData[TREATMENT_ID_KEY],
        name: realData[OTHERS_NAME_KEY],
        duration: realData[OTHERS_DURATION_KEY],
        periodicity: realData[OTHERS_PERIODICITY_KEY],
        detail: realData[OTHERS_DETAIL_KEY],
        recommendation: realData[OTHERS_RECOMMENDATION_KEY]);
  }
}
