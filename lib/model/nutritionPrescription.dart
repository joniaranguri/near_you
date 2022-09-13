import '../Constants.dart';

class NutritionPrescription {
  String? databaseId;
  int state = 0;
  String? treatmentId;
  String? name;
  String? carbohydrates;
  String? maxCalories;

  NutritionPrescription(
      {required this.databaseId,
      required this.treatmentId,
      required this.name,
      required this.carbohydrates,
      required this.maxCalories});

  factory NutritionPrescription.empty() {
    return NutritionPrescription(
        databaseId: "",
        treatmentId: "",
        name: "",
        carbohydrates: "",
        maxCalories: "");
  }

  factory NutritionPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return NutritionPrescription(
        databaseId: snapshot.id,
        treatmentId: realData[TREATMENT_ID_KEY],
        name: realData[NUTRITION_NAME_KEY],
        carbohydrates: realData[NUTRITION_CARBOHYDRATES_KEY],
        maxCalories: realData[NUTRITION_MAX_CALORIES_KEY]);
  }
}
