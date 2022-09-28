import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:age_calculator/age_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:near_you/common/static_common_functions.dart';

import '../Constants.dart';
import '../model/user.dart' as user;
import 'package:intl/intl.dart';

class AdherencePrediction {
  static const String BASE_URL =
      "http://ec2-44-208-142-128.compute-1.amazonaws.com:8501/v1/models/adherence_model:predict";

  static Future<int> getPrediction(user.User patient) async {
    final uri = Uri.parse(BASE_URL);
    LinkedHashMap<dynamic, dynamic> requestBody = await getRequestBody(patient);
    if (requestBody.isEmpty) {
      return ADHERENCE_PREDICTION_ERROR;
    }
    final response = await http.post(uri, body: jsonEncode(requestBody));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    print("RESPONSE:" + response.statusCode.toString());
    if (response.statusCode != HttpStatus.ok) {
      return ADHERENCE_PREDICTION_ERROR;
    }
    double adherencePredictionRaw = decoded[PREDICTIONS_KEY][0][0];
    return (adherencePredictionRaw * 100).toInt();
  }

  static getRequestBody(user.User patient) async {
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(DATA_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: patient.currentTreatment)
        .get();
    if (future.docs.isEmpty) {
      return {};
    }
    double question1 = 0;
    double question2 = 0;
    double question3 = 0;
    double question4 = 0;
    double question5 = 0;
    double question6 = 0;
    double medicationValue = 0;
    double nutritionValue = 0;
    double activitiesValue = 0;
    double examsValue = 0; // not used?
    final int sizeDocs = future.docs.length;
    for (var element in future.docs) {
      //TODO: Review this to not calculate again and again
      var data = element.data();
      question1 += data[DATA_PREGUNTA1_KEY];
      question2 += data[DATA_PREGUNTA2_KEY];
      question3 += data[DATA_PREGUNTA3_KEY];
      question4 += data[DATA_PREGUNTA4_KEY];
      question5 += data[DATA_PREGUNTA5_KEY];
      question6 += data[DATA_PREGUNTA6_KEY];
      medicationValue += data[DATA_MEDICACION_KEY];
      nutritionValue += data[DATA_ALIMENTACION_KEY];
      activitiesValue += data[DATA_ACTIVIDAD_FISICA_KEY];
      examsValue += data[DATA_EXAMENES_KEY];
    }
    String? birthday = patient.birthDay!;
    int age = isNotEmtpy(birthday)
        ? AgeCalculator.age(DateFormat.yMMMMd("en_US").parse(birthday)).years
        : 0;
    String sex = patient.gender ?? NOT_SPECIFIED_VALUE;
    String civilStatus = patient.civilStatus ?? NOT_SPECIFIED_VALUE;
    String educationalLevel = patient.educationalLevel ?? NOT_SPECIFIED_VALUE;
    return {
      "instances": [
        {
          "age": age,
          "sex": sex,
          "marital_status": civilStatus,
          "Education": educationalLevel,
          "Medication_preparation_by": VINCULATED_KEY,
          "medication": 0, //String is not of expected type: int64
          "SAMS_item3": question1 ~/ sizeDocs,
          "SAMS_item10": question2 ~/ sizeDocs,
          "SAMS_item11": question3 ~/ sizeDocs,
          "SAMS_item6": question4 ~/ sizeDocs,
          "SAMS_item15": question5 ~/ sizeDocs,
          "SAMS_item19": question6 ~/ sizeDocs,
          "SAMS_item1": medicationValue ~/ sizeDocs,
          "SAMS_item16": activitiesValue ~/ sizeDocs,
          "SAMS_item17": nutritionValue ~/ sizeDocs,
        }
      ]
    };
  }
}
