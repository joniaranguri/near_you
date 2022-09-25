import '../Constants.dart';

class OthersPrescription {
  String? databaseId;
  int? state;
  String? treatmentId;
  String? name;
  String? duration;
  String? periodicity;
  String? detail;
  String? recommendation;

  OthersPrescription(
      {required this.databaseId,
      required this.treatmentId,
      required this.name,
      required this.duration,
      required this.periodicity,
      required this.detail,
      required this.recommendation});

  factory OthersPrescription.empty() {
    return OthersPrescription(
        databaseId: "",
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
        databaseId: snapshot.id,
        treatmentId: realData[TREATMENT_ID_KEY],
        name: realData[OTHERS_NAME_KEY],
        duration: realData[OTHERS_DURATION_KEY],
        periodicity: realData[OTHERS_PERIODICITY_KEY],
        detail: realData[OTHERS_DETAIL_KEY],
        recommendation: realData[OTHERS_RECOMMENDATION_KEY]);
  }
}

class ExamnPrescription {
  String? databaseId;
  int? state;
  String? treatmentId;
  String? name;
  String? endDate;
  String? periodicity;

  ExamnPrescription({
     this.databaseId,
     this.treatmentId,
     this.name,
     this.periodicity,
     this.endDate,
  });

  factory ExamnPrescription.empty() {
    return ExamnPrescription(
      databaseId: "",
      treatmentId: "",
      name: "",
      periodicity: "",
      endDate: '',
    );
  }

  factory ExamnPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return ExamnPrescription(
      databaseId: snapshot.id,
      treatmentId: realData[TREATMENT_ID_KEY],
      name: realData[EXAMN_NAME_KEY],
      periodicity: realData[EXAMN_PERIODICITY_KEY],
      endDate: realData[EXAMN_END_DATE_KEY],
    );
  }
}
