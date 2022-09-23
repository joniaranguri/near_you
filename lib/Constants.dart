const String SHOW_INTRO_SLIDE = "SHOW_INTRO_SLIDE";
const String SHOW_ROLE_SELECTION = "SHOW_ROLE_SELECTION";
const String EMAIL_KEY = "email";
const String FULL_NAME_KEY = "fullName";
const String BIRTH_DAY_KEY = "birthDay";
const String PHONE_KEY = "phoneNumber";
const String AGE_KEY = "age";
const String ADDRESS_KEY = "address";
const String MEDICAL_CENTER_VALUE = "medicalCenter";
const String GENDER_KEY = "gender";
const String REFERENCE_KEY = "reference";
const String ALT_PHONE_NUMBER_KEY = "alternativePhone";
const String SMOKING_KEY = "smoking";
const String ALLERGIES_KEY = "allergies";
const String USERS_COLLECTION_KEY = "users";
const String PENDING_VINCULATIONS_COLLECTION_KEY = "pendingVinculations";
const String USER_TYPE = "type";
const String USER_ILLNESS = "illness";
const String USER_TYPE_MEDICO = "MEDICO";
const String USER_TYPE_PACIENTE = "PACIENTE";
const String TREATMENTS_KEY = "treatments";
const String PRESCRIPTIONS_KEY = "prescriptions";
const String ATTACHED_PATIENTS = "attachedPatients";
const String MEDICO_ID_KEY = "medicoId";
const String PATIENT_ID_KEY = "patientId";
const String USER_ID_KEY = "userId";
const String VINCULATIONS_KEY = "vinculations";
const String ADHERENCE_LEVEL_KEY = "adherenceLevel";
const String PATIENT_CURRENT_TREATMENT_KEY = "currentTreatment";
const String EMPTY_STRING_VALUE = "";

const String TREATMENT_ID_KEY = "treatmentId";
const String TREATMENT_DATABASE_ID = "databaseId";
const String TREATMENT_START_DATE_KEY = "startDate";
const String TREATMENT_END_DATE_KEY = "endDate";
const String TREATMENT_DURATION_NUMBER_KEY = "durationNumber";
const String TREATMENT_DURATION_TYPE_KEY = "durationType";
const String TREATMENT_DESCRIPTION_KEY = "description";
const String TREATMENT_PRESCRIPTIONS_KEY = "prescriptions";
const String TREATMENT_STATE_KEY = "state";

const String PRESCRIPTIONS_COLLECTION_KEY = "prescriptions";

const String OTHERS_NAME_KEY = "name";
const String OTHERS_DURATION_KEY = "duration";
const String OTHERS_PERIODICITY_KEY = "periodicity";
const String OTHERS_DETAIL_KEY = "detail";
const String OTHERS_RECOMMENDATION_KEY = "recommendation";

const String ACTIVITY_NAME_KEY = "name";
const String ACTIVITY_ACTIVITY_KEY = "activity";
const String ACTIVITY_PERIODICITY_KEY = "periodicity";
const String ACTIVITY_CALORIES_KEY = "calories";
const String ACTIVITY_TIME_NUMBER_KEY = "timeNumber";
const String ACTIVITY_TIME_TYPE_KEY = "timeType";

const String MEDICATION_NAME_KEY = "name";
const String MEDICATION_START_DATE_KEY = "startDate";
const String MEDICATION_DURATION_NUMBER_KEY = "durationNumber";
const String MEDICATION_DURATION_TYPE_KEY = "durationType";
const String MEDICATION_PASTILLE_TYPE_KEY = "pastilleType";
const String MEDICATION_DOSE_KEY = "dose";
const String MEDICATION_QUANTITY_KEY = "quantity";
const String MEDICATION_PERIODICITY_KEY = "periodicity";
const String MEDICATION_RECOMMENDATION_KEY = "recomendation";

const String NUTRITION_NAME_KEY = "name";
const String NUTRITION_CARBOHYDRATES_KEY = "carbohydrates";
const String NUTRITION_MAX_CALORIES_KEY = "maxCalories";

const String MEDICATION_PRESCRIPTION_COLLECTION_KEY = "medicationPrescriptions";
const String NUTRITION_PRESCRIPTION_COLLECTION_KEY = "nutritionPrescriptions";
const String ACTIVITY_PRESCRIPTION_COLLECTION_KEY = "activityPrescriptions";
const String OTHERS_PRESCRIPTION_COLLECTION_KEY = "othersPrescriptions";

const String PENDING_MEDICATION_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingMedicationPrescriptions";
const String PENDING_NUTRITION_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingNutritionPrescriptions";
const String PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingActivityPrescriptions";
const String PENDING_Others_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingOthersPrescriptions";
const String PENDING_PRESCRIPTIONS_TREATMENT_KEY = "pendingTreatmentId";
const String PENDING_PRESCRIPTIONS_ID_KEY = "pendingPrescriptionId";

const String PERMITTED_KEY = "permitted";
const String YES_KEY = "yes";
const String NO_KEY = "no";

const String APPLICANT_VINCULATION_USER_TYPE = "applicantType";

//TODO  Chequear el mostrar el role selection si es otro user

const List<String> durationsList = ["días", "semanas", "meses", "años"];
const List<String> otherNamesList = [
  "Insulina",
  "Nivel de HbA1c",
  "LDL",
  "HDL",
  "Triglicérido",
  "Colesterol",
  "Riesgo cardiovascular"
];
const List<String> durationsActivityList = ["horas", "segundos", "horas"];
const List<String> pastilleTypeList = ["Pastilla antidiabética", "Otro tipo"];
const List<String> pastilleQuantitiesList = [
  "1 pastilla",
  "2 pastillas",
  "3 pastillas",
  "4 pastillas",
  "5 pastillas"
];
const List<String> periodicityList = ["Diaria", "Semanal", "Mensual"];

const String SURVEY_COLLECTION_KEY = "surveys";
const String SURVEY_TIMESTAMP_KEY = "timestamp";

const String VINCULATION_STATUS_KEY = "vinculationStatus";
const String VINCULATION_STATUS_PENDING = "pending";
const String VINCULATION_STATUS_ACCEPTED = "accepted";
const String VINCULATION_STATUS_REFUSED = "refused";
const String VINCULATION_PENDING_NAME_KEY = "pendingName";
const String VINCULATION_PENDING_EMAIL_KEY = "pendingEmail";

const String ROUTINE_MEDICATION_PERCENTAGE_KEY = "medicationPercentage";
const String ROUTINE_NUTRITION_PERCENTAGE_KEY = "nutritionPercentage";
const String ROUTINE_ACTIVITY_PERCENTAGE_KEY = "activityPercentage";
const String ROUTINE_EXAMS_PERCENTAGE_KEY = "examsPercentage";
const String ROUTINE_TOTAL_PERCENTAGE_KEY = "totalPercentage";
const String ROUTINE_HOUR_COMPLETED_KEY = "hourCompleted";

const String ROUTINES_COLLECTION_KEY = "routines";
const String ROUTINES_RESULTS_KEY = "routinesResults";

const String DATA_COLLECTION_KEY = "data";

const String DATA_EDAD_KEY = "Edad";
const String DATA_SEXO_KEY = "Sexo";
const String DATA_ESTADO_CIVIL_KEY = "EstadoCivil";
const String DATA_NIVEL_EDUCACIONAL_KEY = "NivelEducacional";
const String DATA_FUMA_KEY = "Fuma";
const String DATA_PREGUNTA1_KEY = "Pregunta1";
const String DATA_PREGUNTA2_KEY = "Pregunta2";
const String DATA_PREGUNTA3_KEY = "Pregunta3";
const String DATA_PREGUNTA4_KEY = "Pregunta4";
const String DATA_PREGUNTA5_KEY = "Pregunta5";
const String DATA_PREGUNTA6_KEY = "Pregunta6";
const String DATA_MEDICACION_KEY = "Medicacion";
const String DATA_ALIMENTACION_KEY = "Alimentacion";
const String DATA_ACTIVIDAD_FISICA_KEY = "ActividadFisica";
const String DATA_EXAMENES_KEY = "Examenes";
const String DATA_SUMA_KEY = "Suma";
const String DATA_ADHERENCIA_KEY = "Adherencia";
/*Edad Sexo Estado
Civil
Nivel
Educacional
Fuma Pregunta
1
Pregunta
2
Pregunta
3
Pregunta
4
Pregunta
5
Medicación
20 Hombre Soltero Secundaria
completa
0 1 2 0 0 1 2
Alimentación Actividad física Exámenes Suma Adherencia
0 2 3 (Suma de la columna desde
Fuma + hasta Exámenes) = 11
1 – (11/36) = 0.6*/