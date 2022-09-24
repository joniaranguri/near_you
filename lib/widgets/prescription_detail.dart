import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/model/medicationPrescription.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import '../model/activityPrescription.dart';
import '../model/nutritionPrescription.dart';
import '../model/othersPrescription.dart';
import '../widgets/grouped_bar_chart.dart';

class PrescriptionDetail extends StatefulWidget {
  final bool isDoctorView;
  Treatment? currentTreatment;

  int currentPageIndex;

  PrescriptionDetail(this.currentTreatment,
      {required this.isDoctorView, required this.currentPageIndex});

  factory PrescriptionDetail.forDoctorView(Treatment? paramTreatment, int currentPageIndex) {
    return PrescriptionDetail(paramTreatment,
        isDoctorView: true, currentPageIndex: currentPageIndex);
  }

  factory PrescriptionDetail.forPrescriptionView(Treatment? paramTreatment) {
    return PrescriptionDetail(
      paramTreatment,
      isDoctorView: false,
      currentPageIndex: 0,
    );
  }

  @override
  PrescriptionDetailState createState() =>
      PrescriptionDetailState(currentTreatment, isDoctorView, currentPageIndex);
}

class PrescriptionDetailState extends State<PrescriptionDetail> {
  static StaticComponents staticComponents = StaticComponents();
  Treatment? currentTreatment;
  int _currentPage = 0;
  late final PageController _pageController;
  bool isDoctorView = true;
  late Future<List<MedicationPrescription>> medicationPrescriptionFuture;
  late final Future<List<NutritionPrescription>> nutritionPrescriptionFuture;
  late final Future<List<ActivityPrescription>> activityPrescriptionFuture;
  late final Future<List<OthersPrescription>> othersPrescriptionFuture;
  List<MedicationPrescription> medicationsList = <MedicationPrescription>[];
  List<NutritionPrescription> nutritionList = <NutritionPrescription>[];
  List<ActivityPrescription> activitiesList = <ActivityPrescription>[];
  List<NutritionPrescription> nutritionNoPermittedList = <NutritionPrescription>[];
  List<ActivityPrescription> activitiesNoPermittedList = <ActivityPrescription>[];
  List<OthersPrescription> othersList = <OthersPrescription>[];
  final TextEditingController imcTextController = TextEditingController();

  bool readOnlyMedication = false;
  bool isMedicationLoading = false;
  bool isNutritionLoading = false;
  bool isPhisicalActivityLoading = false;

  String? medicationStartDateValue;
  String? medicationNameValue;
  String? medicationDurationNumberValue;
  String? medicationDurationTypeValue;
  String? medicationTypeValue;
  String? medicationDoseValue;
  String? medicationQuantityValue;
  String? medicationPeriodicityValue;
  String? medicationRecommendationValue;

  String? nutritionNameValue;
  String? nutritionCarboValue;
  String? nutritionCaloriesValue;
  //String? heightValue;
  String? imcValue;
  //String? weightValue;

  String? activityNameValue;
  String? activityActivityValue;
  String? activityPeriodicityValue;
  String? activityCaloriesValue;
  String? activityTimeNumberValue;
  String? activityTimeTypeValue;

  String? othersNameValue;
  String? othersDurationValue;
  String? othersDurationTypeValue;
  String? othersPeriodicityTypeValue;
  String? othersPeriodicityValue;
  String? othersDetailValue;
  String? othersRecommendationValue;

  int medicationsCount = 0;

  final GlobalKey<FormState> medicationFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> alimentationFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> phisicalActivityFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> othersFormState = GlobalKey<FormState>();

  bool startDateError = false;
  bool endDateError = false;
  bool durationError = false;
  bool durationTypeError = false;
  bool stateError = false;
  bool descriptionError = false;

  bool editingMedication = false;
  bool editingExamn = false;

  bool editingPermittedFood = false;
  bool editingPermittedActivity = false;
  bool editingOthers = false;

  int updateMedication = -1;
  int updatePermittedFood = -1;
  int updateNoPermittedFood = -1;
  int updatePermittedActivity = -1;
  int updateNoPermittedActivity = -1;
  int updateOthers = -1;

  PrescriptionDetailState(this.currentTreatment, this.isDoctorView, int currentPageIndex) {
    _pageController = PageController(initialPage: currentPageIndex);
    _currentPage = currentPageIndex;
  }

  get blueIndicator => Expanded(
          child: SizedBox(
        height: 6,
        child: Center(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
                color: const Color(0xff2F8F9D),
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle),
          ),
        ),
      ));

  get grayIndicator => Expanded(
          child: SizedBox(
        height: 6,
        child: Center(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
                color: const Color(0xffCCD6DD),
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle),
          ),
        ),
      ));

  get borderGray => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(5));

  get borderWhite => OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(5));

  get sizedBox10 => const SizedBox(height: 10);

  void refreshMedicationPrescription() async {
    setState(() => isMedicationLoading = true);
    final medications = await getMedicationPrescriptions();
    medicationsList = medications;
    clearMedicationForm();
    setState(() => isMedicationLoading = false);
  }

  void refreshNutritionPrescription() async {
    setState(() => isNutritionLoading = true);
    final nutritions = await getNutritionPrescriptions();
    nutritionList = [];
    nutritionNoPermittedList = [];
    for (int i = 0; i < nutritions.length; i++) {
      if (nutritions[i].permitted == YES_KEY) {
        nutritionList.add(nutritions[i]);
      } else {
        nutritionNoPermittedList.add(nutritions[i]);
      }
    }
    editNotPermittedFood = false;
    editPermittedFood = false;
    foodPermitted = null;
    foodNotPermitted = null;
    setState(() => isNutritionLoading = false);
  }

  void clearMedicationForm() {
    medicationNameValue = null;
    medicationPeriodicityValue = null;
    medicationRecommendationValue = null;
  }

  void refreshActivityPrescription() async {
    setState(() => isPhisicalActivityLoading = true);
    final response = await getActivityPrescriptions();
    activitiesList = response;
    /* setState(() {
        activitiesList = [];
        activitiesNoPermittedList = [];
        for (int i = 0; i < response.length; i++) {
          if (response[i].permitted == YES_KEY) {
            activitiesList.add(response[i]);
          } else {
            activitiesNoPermittedList.add(response[i]);
          }
        }
      }); */
    setState(() => isPhisicalActivityLoading = false);
  }

  @override
  void initState() {
    refreshMedicationPrescription();
    refreshNutritionPrescription();
    refreshActivityPrescription();
    //medicationPrescriptionFuture = getMedicationPrescriptions();
    //nutritionPrescriptionFuture = getNutritionPrescriptions();
    //activityPrescriptionFuture = getActivityPrescriptions();
    othersPrescriptionFuture = getOthersPrescriptions();
    /* medicationPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                medicationsList = value;
              })
            }
        }); */
    /* nutritionPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                nutritionList = [];
                nutritionNoPermittedList = [];
                for (int i = 0; i < value.length; i++) {
                  if (value[i].permitted == YES_KEY) {
                    nutritionList.add(value[i]);
                  } else {
                    nutritionNoPermittedList.add(value[i]);
                  }
                }
              })
            }
        }); */
    /* activityPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                activitiesList = [];
                activitiesNoPermittedList = [];
                for (int i = 0; i < value.length; i++) {
                  if (value[i].permitted == YES_KEY) {
                    activitiesList.add(value[i]);
                  } else {
                    activitiesNoPermittedList.add(value[i]);
                  }
                }
              })
            }
        }); */
    othersPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                othersList = value;
              })
            }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 580,
      width: screenWidth,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: 4,
          itemBuilder: (ctx, i) => getCurrentPageByIndex(ctx, i)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    imcTextController.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  getCurrentPageByIndex(BuildContext ctx, int i) {
    String title = "";
    Widget childView;
    switch (i) {
      case 0:
        title = "Medicación";
        childView = getMedicationView();
        break;
      case 1:
        title = "Alimentación";
        childView = getAlimentationView();
        break;
      case 2:
        title = "Actividad Física";
        childView = getPhisicalActivityView();
        break;
      case 3:
        title = "Exámenes";
        childView = getPhisicalActivityView();
        break;
      default:
        title = "Otros";
        childView = getOthersView();
    }
    return getPrescriptionPage(i, title, childView);
  }

  void goBack() {
    _pageController.animateToPage(
      --_currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void goAhead() {
    _pageController.animateToPage(
      ++_currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  getAdherencePage() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: SizedBox(
        width: 400,
        height: 580,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xff2F8F9D)),
                    onPressed: () {
                      goBack();
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    //apply padding to all four sides
                    child: Text(
                      'Adherencia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2F8F9D),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xff2F8F9D)),
                    onPressed: () {
                      goAhead();
                    },
                  )
                ]),
                const SizedBox(
                  height: 20,
                ),
                CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 10,
                    percent: 0.75,
                    //center: Text("75%", style: TextStyle(color: Color(0xFF1AB600), fontSize: 27, fontWeight: FontWeight.bold, backgroundColor: Colors.red)),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text("75%",
                            style: TextStyle(
                                color: Color(0xff6EC6A4),
                                fontSize: 40,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'ADHERENCIA',
                          style: TextStyle(fontSize: 11, color: Color(0xff666666)),
                        ),
                        Text('NORMAL', style: TextStyle(fontSize: 11, color: Color(0xff666666)))
                      ],
                    ),
                    linearGradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: <Color>[Color(0xff6EC6A4), Color(0xff6EC6A4)]),
                    rotateLinearGradient: true,
                    circularStrokeCap: CircularStrokeCap.round),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  '¡Te felicito, sigue así!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff999999),
                  ),
                )
              ]),
              const SizedBox(
                height: 20,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  //apply padding to all four sides
                  child: Text(
                    'Periodo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffCECECE),
                    ),
                  ),
                ),
                Expanded(
                    child: Divider(
                  color: Color(0xffCECECE),
                  thickness: 1,
                )),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 2),
                  //apply padding to all four sides
                  child: Text(
                    'Lower',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffCECECE),
                    ),
                  ),
                ),
                Text(
                  '53%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Color(0xffF8191E),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Color(0xffF8191E))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 20,
                  color: const Color(0xff3BACB6),
                  textColor: Colors.white,
                  onPressed: () {
                    // _signInWithEmailAndPassword();
                  },
                  child: const Text(
                    'Semanal',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 20,
                  color: const Color(0xff3BACB6),
                  textColor: Colors.white,
                  onPressed: () {
                    // _signInWithEmailAndPassword();
                  },
                  child: const Text(
                    'Semanal',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 20,
                  color: const Color(0xff3BACB6),
                  textColor: Colors.white,
                  onPressed: () {
                    // _signInWithEmailAndPassword();
                  },
                  child: const Text(
                    'Semanal',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                )
              ]),
              SizedBox(height: 76, child: GroupedBarChart.withSampleData()),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: const Color(0xff3BACB6),
                      textColor: Colors.white,
                      onPressed: () {
                        // _signInWithEmailAndPassword();
                      },
                      height: 27,
                      child: const Text(
                        'ver gráficos',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )),
              ]),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[blueIndicator, grayIndicator, grayIndicator]),
              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getPrescriptionPage(int index, String title, Widget childView) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: SizedBox(
        width: 400,
        height: 580,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  IconButton(
                    icon: Icon(index == 0 ? null : Icons.chevron_left,
                        size: 30, color: const Color(0xff2F8F9D)),
                    onPressed: () {
                      if (index > 0) {
                        goBack();
                      }
                    },
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2F8F9D),
                    ),
                  ),
                  IconButton(
                    icon: Icon(index == 3 ? null : Icons.chevron_right,
                        size: 30, color: const Color(0xff2F8F9D)),
                    onPressed: () {
                      if (index < 3) {
                        goAhead();
                      }
                    },
                  )
                ]),
                const SizedBox(
                  height: 10,
                ),
                childView
              ]),
              const SizedBox(
                height: 20,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                index == 0 ? blueIndicator : grayIndicator,
                index == 1 ? blueIndicator : grayIndicator,
                index == 2 ? blueIndicator : grayIndicator,
                index == 3 ? blueIndicator : grayIndicator,
              ]),
              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getMedicationButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  const SizedBox(
                    height: 17,
                  ),
                  SizedBox(
                    height: 27,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: const Color(0xff2F8F9D),
                      textColor: Colors.white,
                      onPressed: () async {
                        await saveMedicationInDatabase();
                        if (mounted) {
                          Navigator.pop(context, _currentPage);
                        }
                      },
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 27,
                      child: FlatButton(
                        height: 27,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(30)),
                        textColor: const Color(0xff9D9CB5),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                ])),
          )
        : const SizedBox(height: 0);
  }

  getAlimentationButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  const SizedBox(
                    height: 17,
                  ),
                  SizedBox(
                    height: 27,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: const Color(0xff2F8F9D),
                      textColor: Colors.white,
                      onPressed: saveEachFoodInDatabase,
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 27,
                      child: FlatButton(
                        height: 27,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(30)),
                        textColor: const Color(0xff9D9CB5),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                ])),
          )
        : const SizedBox(height: 0);
  }

  getActivityButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  const SizedBox(
                    height: 17,
                  ),
                  SizedBox(
                    height: 27,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: const Color(0xff2F8F9D),
                      textColor: Colors.white,
                      onPressed: () async {
                        await saveActivityInDatabase();
                        if (mounted) {
                          Navigator.pop(context, _currentPage);
                        }
                      },
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 27,
                      child: FlatButton(
                        height: 27,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(30)),
                        textColor: const Color(0xff9D9CB5),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                ])),
          )
        : const SizedBox(height: 0);
  }

  getMedicationView() {
    return SizedBox(
      width: double.infinity,
      height: 470,
      child: isMedicationLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text("Medicamentos ",
                              style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                        ],
                      ),
                      sizedBox10,
                      SizedBox(
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: medicationsList.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding: const EdgeInsets.only(bottom: 40),
                                          onPressed: () {
                                            setState(() {
                                              readOnlyMedication = !readOnlyMedication;
                                            });
                                            fillMedicationFormWithValues(index);
                                          },
                                          icon: const Icon(Icons.keyboard_arrow_down,
                                              size: 30,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    SizedBox(
                                        height: 35,
                                        width: 150,
                                        child: Text(medicationsList[index].name ?? "Medicacion",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14, color: Color(0xff999999)))),
                                    SizedBox(
                                        height: 35,
                                        width: 14,
                                        child: IconButton(
                                          padding: const EdgeInsets.only(bottom: 14),
                                          onPressed: () {
                                            editMedication(index);
                                          },
                                          icon: const Icon(Icons.edit,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding: const EdgeInsets.only(bottom: 30),
                                          onPressed: () {
                                            deleteMedication(index);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ))
                                  ],
                                );
                              })),
                      sizedBox10,
                      getFormOrButtonAddMedication()
                    ],
                  ))),
    );
  }

  Future<List<MedicationPrescription>> getMedicationPrescriptions() async {
    List<MedicationPrescription> resultList = <MedicationPrescription>[];
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(MedicationPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  Future<List<ActivityPrescription>> getActivityPrescriptions() async {
    List<ActivityPrescription> resultList = <ActivityPrescription>[];
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(ActivityPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  Future<List<NutritionPrescription>> getNutritionPrescriptions() async {
    List<NutritionPrescription> resultList = <NutritionPrescription>[];
    final db = FirebaseFirestore.instance;
    //El databaseId cambia siempre que entramos en la pantalla
    var future = await db
        .collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(NutritionPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  Future<List<OthersPrescription>> getOthersPrescriptions() async {
    List<OthersPrescription> resultList = <OthersPrescription>[];
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(OTHERS_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(OthersPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  showSuccessDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Operación\nExitosa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600, color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Se eliminó correctamente el\ntratamiento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff67757F))),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                        const SizedBox(
                          height: 17,
                        ),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(15),
                          color: const Color(0xff3BACB6),
                          textColor: Colors.white,
                          onPressed: () {
                            goBackScreen();
                          },
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        )
                      ]),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  ))
            ])
          ],
        );
      },
    );
  }

  bool isNotEmpty(String? str) {
    return str != null && str != '';
  }

  void goBackScreen() {
    if (isDoctorView) {
      Navigator.pop(context);
    }
    /*  Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => isDoctorView
                ? PrescriptionDetailScreen(detailedUser!.userId!)
                : HomeScreen()));*/
  }

  /* void validateAndSave() {
   final FormState? form = medicationFormState.currentState;
    bool durationValid = isNotEmtpy(durationTypeValue);
    bool stateValid = isNotEmtpy(pastilleValue);
    bool isValidDropdowns = durationValid && stateValid;
    durationTypeError = !durationValid;
    stateError = !stateValid;
    if ((form?.validate() ?? false) && isValidDropdowns) {
      //saveIdDatabase();
    }
  }*/

  getFormOrButtonAddExamn() {
    if (editingExamn) {
      return SizedBox(
        width: double.infinity,
        height: 400,
        child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 200,
                ),
                child: Form(
                    //key: medicationFormState,
                    child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          sizedBox10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: durationError ? 55 : 35,
                                width: 220,
                                child: TextFormField(
                                    controller: TextEditingController(text: medicationNameValue),
                                    onChanged: (value) {
                                      medicationNameValue = value;
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    decoration: staticComponents
                                        .getMiddleInputDecoration('Nombre del examen')),
                              ),
                              Flexible(
                                  child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() {
                                    editingMedication = false;
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(15))),
                                  height: 30,
                                  width: 30,
                                  child: const Icon(Icons.check, color: Color(0xff999999)),
                                ),
                              ))
                            ],
                          ),
                          sizedBox10,

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Periodicidad",
                                  style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: stateError ? Colors.red : const Color(0xFF999999),
                                  width: 1),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(10) //         <--- border radius here
                                  ),
                            ),
                            child: SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    hint: const Text(
                                      'Seleccionar',
                                      style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                    ),
                                    dropdownColor: Colors.white,
                                    value: medicationPeriodicityValue,
                                    icon: const Padding(
                                      padding: EdgeInsetsDirectional.only(end: 12.0),
                                      child: Icon(Icons.keyboard_arrow_down,
                                          color:
                                              Color(0xff999999)), // myIcon is a 48px-wide widget.
                                    ),
                                    onChanged: (newValue) {
                                      setState(() {
                                        medicationPeriodicityValue = newValue.toString();
                                      });
                                    },
                                    items: periodicityList.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Recomendación",
                                  style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          TextFormField(
                            validator: (value) {
                              if (value == null || value == '') {
                                setState(() {
                                  durationError = true;
                                });
                                return "Complete el campo";
                              }
                              setState(() {
                                durationError = false;
                              });
                              return null;
                            },
                            controller: TextEditingController(text: medicationRecommendationValue),
                            onChanged: (value) {
                              medicationRecommendationValue = value;
                            },
                            style: const TextStyle(fontSize: 14),
                            minLines: 2,
                            maxLines: 10,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: staticComponents.getBigInputDecoration('Agregar texto'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // getPrescriptionButtons()
                        ],
                      ),
                    ),
                    getMedicationButtons()
                  ],
                )))),
      );
    }
    return GestureDetector(
        onTap: () {
          setState(() {
            editingMedication = true;
          });
        },
        child: TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "Agregar medicamento",
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            ));
  }

  getFormOrButtonAddMedication() {
    if (editingMedication || readOnlyMedication) {
      return SizedBox(
        width: double.infinity,
        height: 400,
        child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 200,
                ),
                child: Form(
                    key: medicationFormState,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xffD9D9D9),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Column(
                            children: [
                              sizedBox10,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  DisableWidget(
                                    isDisable: readOnlyMedication,
                                    child: SizedBox(
                                      height: durationError ? 55 : 35,
                                      width: 220,
                                      child: TextFormField(
                                          controller:
                                              TextEditingController(text: medicationNameValue),
                                          onChanged: (value) {
                                            medicationNameValue = value;
                                          },
                                          style: const TextStyle(fontSize: 14),
                                          decoration: staticComponents
                                              .getMiddleInputDecoration('Nombre del medicamento')),
                                    ),
                                  ),
                                  DisableWidget(
                                    isDisable: readOnlyMedication,
                                    child: Flexible(
                                        child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () async {
                                        setState(() {
                                          editingMedication = false;
                                        });
                                        await saveMedicationInDatabase();
                                        refreshMedicationPrescription();
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(15))),
                                        height: 30,
                                        width: 30,
                                        child: const Icon(Icons.check, color: Color(0xff999999)),
                                      ),
                                    )),
                                  )
                                ],
                              ),
                              sizedBox10,
                              /* Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Fecha de inicio",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff999999)))
                                ],
                              ),
                              sizedBox10,
                              SizedBox(
                                  height: startDateError ? 55 : 35,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value == '') {
                                        setState(() {
                                          startDateError = true;
                                        });
                                        return "Complete el campo";
                                      }
                                      setState(() {
                                        startDateError = false;
                                      });
                                    },
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: medicationStartDateValue),
                                    onTap: () {
                                      selectStartDate(context);
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        filled: true,
                                        prefixIcon: IconButton(
                                          padding: EdgeInsets.only(bottom: 5),
                                          onPressed: () {},
                                          icon: const Icon(
                                              Icons.calendar_today_outlined,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ),
                                        hintText: '18 - Jul 2022  15:00',
                                        hintStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)),
                                        contentPadding: EdgeInsets.zero,
                                        enabledBorder:
                                            staticComponents.middleInputBorder,
                                        border:
                                            staticComponents.middleInputBorder,
                                        focusedBorder:
                                            staticComponents.middleInputBorder),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Duración",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff999999)))
                                ],
                              ),
                              sizedBox10,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Flexible(
                                    child: SizedBox(
                                        height: durationError ? 55 : 35,
                                        width: 111,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null || value == '') {
                                              setState(() {
                                                durationError = true;
                                              });
                                              return "Complete el campo";
                                            }
                                            setState(() {
                                              durationError = false;
                                            });
                                          },
                                          controller: TextEditingController(
                                              text:
                                                  medicationDurationNumberValue),
                                          onChanged: (value) {
                                            medicationDurationNumberValue =
                                                value;
                                          },
                                          style: const TextStyle(fontSize: 14),
                                          decoration: staticComponents
                                              .getMiddleInputDecoration('15'),
                                        )),
                                  ),
                                  Flexible(
                                      child: SizedBox(
                                          height: 35,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: durationTypeError
                                                      ? Colors.red
                                                      : Color(0xFF999999),
                                                  width: 1),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      10) //         <--- border radius here
                                                  ),
                                            ),
                                            child: Container(
                                              width: 150,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: ButtonTheme(
                                                  alignedDropdown: true,
                                                  child: DropdownButton<String>(
                                                    hint: Text(
                                                      'Seleccionar',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFF999999)),
                                                    ),
                                                    dropdownColor: Colors.white,
                                                    value:
                                                        medicationDurationTypeValue,
                                                    icon: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .only(end: 12.0),
                                                      child: Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: Color(
                                                              0xff999999)), // myIcon is a 48px-wide widget.
                                                    ),
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        medicationDurationTypeValue =
                                                            newValue.toString();
                                                      });
                                                    },
                                                    items: durationsList
                                                        .map((String item) {
                                                      return DropdownMenuItem(
                                                        value: item,
                                                        child: Text(
                                                          item,
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )))
                                ],
                              ),
                              sizedBox10,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tipo",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff999999)))
                                ],
                              ),
                              sizedBox10,
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: stateError
                                          ? Colors.red
                                          : Color(0xFF999999),
                                      width: 1),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10) //         <--- border radius here
                                      ),
                                ),
                                child: Container(
                                  height: 35,
                                  width: double.infinity,
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        hint: Text(
                                          'Seleccionar',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF999999)),
                                        ),
                                        dropdownColor: Colors.white,
                                        value: medicationTypeValue,
                                        icon: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 12.0),
                                          child: Icon(Icons.keyboard_arrow_down,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ),
                                        onChanged: (newValue) {
                                          setState(() {
                                            medicationTypeValue =
                                                newValue.toString();
                                          });
                                        },
                                        items:
                                            pastilleTypeList.map((String item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Dosis",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff999999)))
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  height: durationError ? 55 : 35,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value == '') {
                                        setState(() {
                                          durationError = true;
                                        });
                                        return "Complete el campo";
                                      }
                                      setState(() {
                                        durationError = false;
                                      });
                                    },
                                    controller: TextEditingController(
                                        text: medicationDoseValue),
                                    onChanged: (value) {
                                      medicationDoseValue = value;
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    decoration: staticComponents
                                        .getMiddleInputDecoration(
                                            'Después del almuerzo'),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Cantidad",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff999999)))
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: stateError
                                          ? Colors.red
                                          : Color(0xFF999999),
                                      width: 1),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10) //         <--- border radius here
                                      ),
                                ),
                                child: Container(
                                  height: 35,
                                  width: double.infinity,
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        hint: Text(
                                          'Seleccionar',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF999999)),
                                        ),
                                        dropdownColor: Colors.white,
                                        value: medicationQuantityValue,
                                        icon: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 12.0),
                                          child: Icon(Icons.keyboard_arrow_down,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ),
                                        onChanged: (newValue) {
                                          setState(() {
                                            medicationQuantityValue =
                                                newValue.toString();
                                          });
                                        },
                                        items: pastilleQuantitiesList
                                            .map((String item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              sizedBox10, */
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Periodicidad",
                                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                                ],
                              ),
                              sizedBox10,
                              DisableWidget(
                                isDisable: readOnlyMedication,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: stateError ? Colors.red : const Color(0xFF999999),
                                        width: 1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10) //         <--- border radius here
                                        ),
                                  ),
                                  child: SizedBox(
                                    height: 35,
                                    width: double.infinity,
                                    child: DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        alignedDropdown: true,
                                        child: DropdownButton<String>(
                                          hint: const Text(
                                            'Seleccionar',
                                            style:
                                                TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                          ),
                                          dropdownColor: Colors.white,
                                          value: medicationPeriodicityValue,
                                          icon: const Padding(
                                            padding: EdgeInsetsDirectional.only(end: 12.0),
                                            child: Icon(Icons.keyboard_arrow_down,
                                                color: Color(
                                                    0xff999999)), // myIcon is a 48px-wide widget.
                                          ),
                                          onChanged: (newValue) {
                                            setState(() {
                                              medicationPeriodicityValue = newValue.toString();
                                            });
                                          },
                                          items: periodicityList.map((String item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              sizedBox10,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Descripción",
                                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                                ],
                              ),
                              sizedBox10,
                              DisableWidget(
                                isDisable: readOnlyMedication,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value == '') {
                                      setState(() {
                                        durationError = true;
                                      });
                                      return "Complete el campo";
                                    }
                                    setState(() {
                                      durationError = false;
                                    });
                                    return null;
                                  },
                                  controller:
                                      TextEditingController(text: medicationRecommendationValue),
                                  onChanged: (value) {
                                    medicationRecommendationValue = value;
                                  },
                                  style: const TextStyle(fontSize: 14),
                                  minLines: 2,
                                  maxLines: 10,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration:
                                      staticComponents.getBigInputDecoration('Agregar texto'),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // getPrescriptionButtons()
                            ],
                          ),
                        ),
                        if (readOnlyMedication == false) getMedicationButtons()
                      ],
                    )))),
      );
    }
    return GestureDetector(
        onTap: () {
          setState(() {
            editingMedication = true;
          });
        },
        child: TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "Agregar medicamento",
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            ));
  }

  final formKey = GlobalKey<FormState>();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  Widget getAlimentationView() {
    return Container(
      width: double.infinity,
      height: 470,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isNutritionLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Peso", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                          ],
                        ),
                        sizedBox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: SizedBox(
                                  width: 150,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value == '') {
                                        return "Complete el campo";
                                      }

                                      return null;
                                    },
                                    controller: weightController,

                                    style: const TextStyle(fontSize: 14),
                                    decoration: staticComponents.getMiddleInputDecoration('56'),
                                    keyboardType: TextInputType.number,
                                    onFieldSubmitted: _calculateIMC,
                                    //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    //keyboardType: TextInputType.number,
                                  )),
                            ),
                            const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Kg',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                ))
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Estatura",
                                style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                          ],
                        ),
                        sizedBox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: SizedBox(
                                //height: heightError ? 55 : 35,
                                width: 180,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value == '') {
                                      return "Complete el campo";
                                    }
                                    double height = double.parse(value);
                                    if (height > 2.5 || height < 0.30) {
                                      return "Valido solo entre 0.30 y 2.5";
                                    }

                                    return null;
                                  },
                                  controller: heightController,
                                  /*  onChanged: (value) {
                                    heightValue = value;
                                  }, */
                                  onFieldSubmitted: _calculateIMC,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: staticComponents.getMiddleInputDecoration('1.65'),
                                  keyboardType: TextInputType.number,
                                  //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'm',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                ))
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text("IMC ", style: TextStyle(fontSize: 14, color: Color(0xff999999))),
                            Icon(Icons.info, size: 18, color: Color(0xff999999))
                          ],
                        ),
                        sizedBox10,
                        SizedBox(
                            height: 35,
                            child: TextFormField(
                              enabled: false,
                              controller: imcTextController,
                              /* validator: (value) {
                                    if (value == null || value == '') {
                                      setState(() {
                                        durationError = true;
                                      });
                                      return "Complete el campo";
                                    }
                                    setState(() {
                                      durationError = false;
                                    });
                                    return null;
                                  }, */
                              //controller: TextEditingController(text: imcValue),
                              /* onChanged: (value) {
                                    imcValue = value;
                                  }, */
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  filled: true,
                                  fillColor: const Color(0xffD9D9D9),
                                  hintText: '17.5',
                                  hintStyle:
                                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                  enabledBorder: StaticComponents().middleInputBorder,
                                  border: StaticComponents().middleInputBorder,
                                  focusedBorder: StaticComponents().middleInputBorder),
                            )),
                        sizedBox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text("Alimentos permitidos ",
                                style: TextStyle(fontSize: 14, color: Color(0xff999999))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        getPermittedFoodView(),
                        const SizedBox(height: 10),

                        //sizedBox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text("Alimentos no permitidos ",
                                style: TextStyle(fontSize: 14, color: Color(0xff999999))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        getNotPermittedFoodView(),
                        const SizedBox(height: 10),

                        /*   Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text("Alimentación ",
                                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
                                Icon(Icons.info, size: 18, color: Color(0xff999999))
                              ],
                            ),
                            sizedBox10, */

                        /* getButtonAddFoodOrList(),
                            sizedBox10,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text("Alimentos no permitidos",
                                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
                              ],
                            ), */
                        //sizedBox10,

                        //getButtonAddFoodOrListProhibited(),
                        const SizedBox(
                          height: 32,
                        ),
                        getAlimentationButtons()
                      ],
                    ),
                  ))),
    );
  }

  int currentPermitedFoodIndex = 0;
  bool readOnlyPermittedFood = false;

  Widget getPermittedFoodView() {
    return Column(
      children: [
        ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 100,
            ),
            //height: nutritionList.isNotEmpty ? 100 : null,
            child: Scrollbar(
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: nutritionList.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            height: 35,
                            child: IconButton(
                              padding: const EdgeInsets.only(bottom: 40),
                              onPressed: () {
                                /* setState(() {
                                  readOnlyPermittedFood = !readOnlyPermittedFood;
                                }); */
                              },
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 30,
                                  color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                            )),
                        const SizedBox(width: 10),
                        SizedBox(
                            height: 35,
                            child: Text(nutritionList[index].name ?? "Alimento",
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 14, color: Color(0xff999999)))),
                        const Spacer(),
                        SizedBox(
                            height: 35,
                            width: 14,
                            child: IconButton(
                              padding: const EdgeInsets.only(bottom: 14),
                              onPressed: () {
                                //editFood(index, true);
                                setState(() {
                                  editPermittedFood = true;
                                  addNewPermittedfood = false;
                                });
                                currentPermitedFoodIndex = index;
                                foodPermitted = nutritionList[index].name;
                              },
                              icon: const Icon(Icons.edit,
                                  color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                            )),
                        const SizedBox(width: 10),
                        SizedBox(
                            height: 35,
                            child: IconButton(
                              padding: const EdgeInsets.only(bottom: 30),
                              onPressed: () {
                                deleteNutritionPermitted(index, true);
                              },
                              icon: const Icon(Icons.delete,
                                  color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                            ))
                      ],
                    );
                  }),
            )),
        switchAddNutritionButtonOrForm(),
      ],
    );
  }

  bool editPermittedFood = false;
  bool addNewPermittedfood = false;
  String? foodPermitted;

  switchAddNutritionButtonOrForm() {
    return editPermittedFood || addNewPermittedfood
        ? Container(
            width: 250,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: 185,
                    child: TextFormField(
                        controller: TextEditingController(text: foodPermitted),
                        onChanged: (value) {
                          foodPermitted = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: staticComponents.getMiddleInputDecoration('Frutas')),
                  ),
                  Flexible(
                      child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      if (!formKey.currentState!.validate() || foodPermitted == null) return;
                      if (editPermittedFood) {
                        await updateFoodInDatabase(foodPermitted, true, currentPermitedFoodIndex);
                      } else {
                        await saveFoodInDatabase(foodPermitted, true);
                      }
                      editPermittedFood = false;
                      addNewPermittedfood = false;
                      refreshNutritionPrescription();
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15))),
                      height: 30,
                      width: 30,
                      child: const Icon(Icons.check, color: Color(0xff999999)),
                    ),
                  ))
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                editPermittedFood = false;
                addNewPermittedfood = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar alimento",
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ),
          );
  }

  int currentNotPermitedFoodIndex = 0;
  bool readOnlyNotPermittedFood = false;

  Widget getNotPermittedFoodView() {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 100,
          ),
          child: Scrollbar(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nutritionNoPermittedList.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: const EdgeInsets.only(bottom: 40),
                            onPressed: () {},
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 30,
                                color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      const SizedBox(width: 10),
                      SizedBox(
                          height: 35,
                          child: Text(nutritionNoPermittedList[index].name ?? "Actividad",
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 14, color: Color(0xff999999)))),
                      const Spacer(),
                      SizedBox(
                          height: 35,
                          width: 14,
                          child: IconButton(
                            padding: const EdgeInsets.only(bottom: 14),
                            onPressed: () {
                              //editFood(index, false);
                              setState(() {
                                editNotPermittedFood = true;
                                addNewNotPermittedfood = false;
                              });
                              currentNotPermitedFoodIndex = index;
                              foodPermitted = nutritionNoPermittedList[index].name;
                            },
                            icon: const Icon(Icons.edit,
                                color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      const SizedBox(width: 10),
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: const EdgeInsets.only(bottom: 30),
                            onPressed: () {
                              deleteNutritionPermitted(index, false);
                            },
                            icon: const Icon(Icons.delete,
                                color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                          ))
                    ],
                  );
                }),
          ),
        ),
        switchAddNotPermittedNutritionButtonOrForm(),
      ],
    );
  }

  bool editNotPermittedFood = false;
  bool addNewNotPermittedfood = false;
  String? foodNotPermitted;

  switchAddNotPermittedNutritionButtonOrForm() {
    return editNotPermittedFood || addNewNotPermittedfood
        ? Container(
            width: 250,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: 185,
                    child: TextFormField(
                        controller: TextEditingController(text: foodNotPermitted),
                        onChanged: (value) {
                          foodNotPermitted = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: staticComponents.getMiddleInputDecoration('Dulces')),
                  ),
                  Flexible(
                      child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      if (!formKey.currentState!.validate() || foodNotPermitted == null) return;
                      if (editNotPermittedFood) {
                        await updateFoodInDatabase(
                            foodNotPermitted, false, currentNotPermitedFoodIndex);
                      } else {
                        await saveFoodInDatabase(foodNotPermitted, false);
                      }
                      editNotPermittedFood = false;
                      addNewNotPermittedfood = false;
                      refreshNutritionPrescription();
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15))),
                      height: 30,
                      width: 30,
                      child: const Icon(Icons.check, color: Color(0xff999999)),
                    ),
                  ))
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                editNotPermittedFood = false;
                addNewNotPermittedfood = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar alimento",
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ));
  }

  getPhisicalActivityView() {
    return Container(
      width: double.infinity,
      height: 470,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isPhisicalActivityLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: activitiesList.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding: const EdgeInsets.only(bottom: 40),
                                          onPressed: () {
                                            setState(() {
                                              readOnlyActivity = !readOnlyActivity;
                                            });
                                            fillActivityFormWithValues(index);
                                          },
                                          icon: const Icon(Icons.keyboard_arrow_down,
                                              size: 30,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    SizedBox(
                                        height: 35,
                                        child: Text(activitiesList[index].name ?? "Actividad",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14, color: Color(0xff999999)))),
                                    const Spacer(),
                                    SizedBox(
                                        height: 35,
                                        width: 14,
                                        child: IconButton(
                                          padding: const EdgeInsets.only(bottom: 14),
                                          onPressed: () {
                                            editActivity(index);
                                          },
                                          icon: const Icon(Icons.edit,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding: const EdgeInsets.only(bottom: 30),
                                          onPressed: () {
                                            deleteActivity(index);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ))
                                  ],
                                );
                              })),
                      sizedBox10,
                      getFormOrButtonActivity(),

                      /*  buildPhisicalActivityForm(),
                      getActivityButtons(), */
                    ],
                  ))),
    );
  }

  bool editingActivity = false;
  bool addNewActivity = false;
  bool readOnlyActivity = false;

  Widget getFormOrButtonActivity() {
    if (editingActivity || readOnlyActivity || addNewActivity) {
      return Column(
        children: [
          DisableWidget(isDisable: readOnlyActivity, child: buildPhisicalActivityForm()),
          if (readOnlyActivity == false) getActivityButtons()
        ],
      );
    }

    return GestureDetector(
        onTap: () {
          setState(() {
            editingActivity = false;
            addNewActivity = true;
          });
        },
        child: TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "Agregar Actividad",
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            ));
  }

  final TextEditingController activityNameFormValue = TextEditingController();
  final TextEditingController activityTimeFormValue = TextEditingController();
  String? activityDurationFormValue;

  Widget buildPhisicalActivityForm() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xffD9D9D9),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                  width: 185,
                  child: TextFormField(
                      controller: activityNameFormValue,
                      /* onChanged: (value) {
                        activityNameFormValue = value;
                      }, */
                      style: const TextStyle(fontSize: 14),
                      decoration:
                          staticComponents.getMiddleInputDecoration('Nombre de la actividad')),
                ),
                Flexible(
                    child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    /* setState(() {
                      editingActivity = false;
                    });
                    await saveMedicationInDatabase();
                    refreshActivityPrescription(); */
                    setState(() {
                      isPhisicalActivityLoading = true;
                    });
                    await saveActivityInDatabase();
                    addNewActivity = false;
                    editingActivity = false;
                    refreshActivityPrescription();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15))),
                    height: 30,
                    width: 30,
                    child: const Icon(Icons.check, color: Color(0xff999999)),
                  ),
                ))
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Tiempo", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: SizedBox(
                    height: 35,
                    child: TextFormField(
                      controller: activityTimeFormValue,
                      /* controller: TextEditingController(text: medicationNameValue),
                      onChanged: (value) {
                        activityTimeFormValue = value;
                      }, */
                      style: const TextStyle(fontSize: 14),
                      decoration: staticComponents.getMiddleInputDecoration('2'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: SizedBox(
                      width: 140,
                      height: 35,
                      child: Container(
                        //color: Colors.white,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: durationTypeError ? Colors.red : const Color(0xFF999999),
                              width: 1),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10) //         <--- border radius here
                              ),
                        ),
                        child: SizedBox(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                hint: Text(
                                  activityDurationFormValue ?? 'Horas',
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                ),
                                dropdownColor: Colors.white,
                                value: activityDurationFormValue,
                                icon:
                                    const Icon(Icons.keyboard_arrow_down, color: Color(0xff999999)),
                                onChanged: (newValue) {
                                  setState(() {
                                    activityDurationFormValue = newValue;
                                  });

                                  /* setState(() {
                                    //durationTypeValue = newValue.toString();
                                  }); */
                                },
                                items: ['Horas', 'Minutos'].map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getOthersView() {
    return FutureBuilder(
        future: othersPrescriptionFuture,
        builder: (context, AsyncSnapshot<List<OthersPrescription>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              width: double.infinity,
              height: 470,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 200,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text("Insulina ",
                                  style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: othersList.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                            height: 35,
                                            child: IconButton(
                                              padding: const EdgeInsets.only(bottom: 40),
                                              onPressed: () {},
                                              icon: const Icon(Icons.keyboard_arrow_down,
                                                  size: 30,
                                                  color: Color(
                                                      0xff999999)), // myIcon is a 48px-wide widget.
                                            )),
                                        SizedBox(
                                            height: 35,
                                            width: 150,
                                            child: Text(othersList[index].name ?? "Medicacion",
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    fontSize: 14, color: Color(0xff999999)))),
                                        SizedBox(
                                            height: 35,
                                            width: 14,
                                            child: IconButton(
                                              padding: const EdgeInsets.only(bottom: 14),
                                              onPressed: () {
                                                editOthers(index);
                                              },
                                              icon: const Icon(Icons.edit,
                                                  color: Color(
                                                      0xff999999)), // myIcon is a 48px-wide widget.
                                            )),
                                        SizedBox(
                                            height: 35,
                                            child: IconButton(
                                              padding: const EdgeInsets.only(bottom: 30),
                                              onPressed: () {
                                                deleteOthers(index);
                                              },
                                              icon: const Icon(Icons.delete,
                                                  color: Color(
                                                      0xff999999)), // myIcon is a 48px-wide widget.
                                            ))
                                      ],
                                    );
                                  })),
                          getButtonOrOthersList(),
                          const SizedBox(height: 2),
                          getSelectOtherName(),
                          getOthersButtons()
                        ],
                      ))),
            );
          }
          return const SizedBox(
            height: 460,
          );
        });
  }

  /* getButtonAddFoodOrList() {
    return !editingPermittedFood
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingPermittedFood = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar una nueva\n prescripción",
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: nutritionNameValue),
                        onChanged: (value) {
                          nutritionNameValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Frutas',
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  const Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Carbohidratos", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller: TextEditingController(text: nutritionCarboValue),
                    onChanged: (value) {
                      nutritionCarboValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getMiddleInputDecoration('150-250 gramos'),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías máx.", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller: TextEditingController(text: nutritionCaloriesValue),
                    onChanged: (value) {
                      nutritionCaloriesValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getMiddleInputDecoration('80 Kcal'),
                  )),
            ]));
  } */

  /*  getButtonAddFoodOrListProhibited() {
    return editingPermittedFood
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingPermittedFood = false;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar alimento",
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: nutritionNameValue),
                        onChanged: (value) {
                          nutritionNameValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Frutas',
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  const Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Carbohidratos", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller: TextEditingController(text: nutritionCarboValue),
                    onChanged: (value) {
                      nutritionCarboValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getMiddleInputDecoration('150-250 gramos'),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías máx.", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller: TextEditingController(text: nutritionCaloriesValue),
                    onChanged: (value) {
                      nutritionCaloriesValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getMiddleInputDecoration('80 Kcal'),
                  )),
            ]));
  } */

  getButtonAddRoutineOrList() {
    return !editingPermittedActivity
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingPermittedActivity = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar rutina física",
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: activityNameValue),
                        onChanged: (value) {
                          activityNameValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Caminar',
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  const Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Actividad", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                        width: 61,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 25,
                          onPressed: () {
                            // _signInWithEmailAndPassword();
                          },
                          child: const Text(
                            'L',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff999999),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                        width: 61,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 25,
                          onPressed: () {
                            // _signInWithEmailAndPassword();
                          },
                          color: Colors.white,
                          child: const Text(
                            'M',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff999999),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                        width: 61,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 25,
                          onPressed: () {
                            // _signInWithEmailAndPassword();
                          },
                          child: const Text(
                            'I',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff999999),
                            ),
                          ),
                        ))),
              ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Tiempo", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: SizedBox(
                        height: durationError ? 55 : 35,
                        width: 100,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              setState(() {
                                durationError = true;
                              });
                              return "Complete el campo";
                            }
                            setState(() {
                              durationError = false;
                            });
                            return null;
                          },
                          controller: TextEditingController(text: activityTimeNumberValue),
                          onChanged: (value) {
                            activityTimeNumberValue = value;
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: staticComponents.getMiddleInputDecoration('3'),
                        )),
                  ),
                  SizedBox(
                      height: 35,
                      width: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: durationTypeError ? Colors.red : const Color(0xFF999999),
                              width: 1),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text(
                                  'Seleccionar',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                ),
                                dropdownColor: Colors.white,
                                value: activityTimeTypeValue,
                                icon: const Padding(
                                  padding: EdgeInsetsDirectional.only(end: 12.0),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    activityTimeTypeValue = newValue.toString();
                                  });
                                },
                                items: durationsActivityList.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Periodicidad", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: stateError ? Colors.red : const Color(0xFF999999), width: 1),
                  borderRadius:
                      const BorderRadius.all(Radius.circular(10) //         <--- border radius here
                          ),
                ),
                child: SizedBox(
                  height: 35,
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Seleccionar',
                          style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                        ),
                        dropdownColor: Colors.white,
                        value: activityPeriodicityValue,
                        icon: const Padding(
                          padding: EdgeInsetsDirectional.only(end: 12.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            activityPeriodicityValue = newValue.toString();
                          });
                        },
                        items: periodicityList.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller: TextEditingController(text: activityCaloriesValue),
                    onChanged: (value) {
                      activityCaloriesValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getMiddleInputDecoration('15 Kcal'),
                  )),
            ]));
  }

  getButtonAddProhibitedRoutineOrList() {
    return editingPermittedActivity
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingPermittedActivity = false;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar rutina física",
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: activityNameValue),
                        onChanged: (value) {
                          activityNameValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Caminar',
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  const Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Actividad", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                        width: 61,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 25,
                          onPressed: () {
                            // _signInWithEmailAndPassword();
                          },
                          child: const Text(
                            'L',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff999999),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                        width: 61,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 25,
                          onPressed: () {
                            // _signInWithEmailAndPassword();
                          },
                          color: Colors.white,
                          child: const Text(
                            'M',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff999999),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                        width: 61,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 25,
                          onPressed: () {
                            // _signInWithEmailAndPassword();
                          },
                          child: const Text(
                            'I',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff999999),
                            ),
                          ),
                        ))),
              ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Tiempo", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: SizedBox(
                        height: durationError ? 55 : 35,
                        width: 100,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              setState(() {
                                durationError = true;
                              });
                              return "Complete el campo";
                            }
                            setState(() {
                              durationError = false;
                            });
                            return null;
                          },
                          controller: TextEditingController(text: activityTimeNumberValue),
                          onChanged: (value) {
                            activityTimeNumberValue = value;
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: staticComponents.getMiddleInputDecoration('3'),
                        )),
                  ),
                  SizedBox(
                      height: 35,
                      width: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: durationTypeError ? Colors.red : const Color(0xFF999999),
                              width: 1),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text(
                                  'Seleccionar',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                ),
                                dropdownColor: Colors.white,
                                value: activityTimeTypeValue,
                                icon: const Padding(
                                  padding: EdgeInsetsDirectional.only(end: 12.0),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    activityTimeTypeValue = newValue.toString();
                                  });
                                },
                                items: durationsActivityList.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Periodicidad", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: stateError ? Colors.red : const Color(0xFF999999), width: 1),
                  borderRadius:
                      const BorderRadius.all(Radius.circular(10) //         <--- border radius here
                          ),
                ),
                child: SizedBox(
                  height: 35,
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Seleccionar',
                          style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                        ),
                        dropdownColor: Colors.white,
                        value: activityPeriodicityValue,
                        icon: const Padding(
                          padding: EdgeInsetsDirectional.only(end: 12.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Color(0xff999999)), // myIcon is a 48px-wide widget.
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            activityPeriodicityValue = newValue.toString();
                          });
                        },
                        items: periodicityList.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller: TextEditingController(text: activityCaloriesValue),
                    onChanged: (value) {
                      activityCaloriesValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getMiddleInputDecoration('15 Kcal'),
                  )),
            ]));
  }

  getSelectOtherName() {
    return editingOthers
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingOthers = false;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    prefixIcon: const Icon(Icons.circle, color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xffD9D9D9),
                    hintText: "Seleccionar nombre",
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    focusedBorder: borderGray,
                    border: borderGray,
                    enabledBorder: borderGray,
                    suffixIcon: const Icon(Icons.keyboard_arrow_down))))
        : Container(
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: [
                TextField(
                    minLines: 1,
                    maxLines: 10,
                    enabled: false,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        prefixIcon: const Icon(
                          Icons.circle,
                          color: Color(0xff999999),
                        ),
                        filled: true,
                        fillColor: const Color(0xffD9D9D9),
                        hintText: "Seleccionar nombre",
                        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                        focusedBorder: borderGray,
                        border: borderGray,
                        enabledBorder: borderGray,
                        suffixIcon: const Icon(Icons.keyboard_arrow_down))),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: otherNamesList.length,
                      //  padding: EdgeInsets.only(bottom: 60),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              othersNameValue = otherNamesList[index];
                              editingOthers = true;
                            });
                          },
                          child: SizedBox(
                            height: 42,
                            child: TextField(
                                enabled: false,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  prefixIcon: const Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xffD9D9D9),
                                  hintText: otherNamesList[index],
                                  hintStyle:
                                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                )),
                          ),
                        );
                      }),
                )
              ],
            ));
  }

  getOthersButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  const SizedBox(
                    height: 17,
                  ),
                  SizedBox(
                    height: 27,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: const Color(0xff2F8F9D),
                      textColor: Colors.white,
                      onPressed: saveOtherInDatabase,
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 27,
                      child: FlatButton(
                        height: 27,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(30)),
                        textColor: const Color(0xff9D9CB5),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                ])),
          )
        : const SizedBox(height: 0);
  }

  Future<void> saveOtherInDatabase() async {
    final db = FirebaseFirestore.instance;
    final String currentTreatmentDatabaseId = currentTreatment!.databaseId!;
    final data = <String, String>{
      TREATMENT_ID_KEY: currentTreatmentDatabaseId,
      OTHERS_NAME_KEY: othersNameValue ?? "",
      OTHERS_DURATION_KEY: othersDurationValue ?? "",
      OTHERS_PERIODICITY_KEY: othersPeriodicityValue ?? "",
      OTHERS_DETAIL_KEY: othersDetailValue ?? "",
      OTHERS_RECOMMENDATION_KEY: othersRecommendationValue ?? ""
    };

    var value = await db.collection(OTHERS_PRESCRIPTION_COLLECTION_KEY).add(data);
    saveInPendingList(
        PENDING_Others_PRESCRIPTIONS_COLLECTION_KEY, value.id, currentTreatmentDatabaseId);

    /* then((value) => saveInPendingListAndGoBack(
        PENDING_Others_PRESCRIPTIONS_COLLECTION_KEY, value.id, currentTreatmentDatabaseId)); */
  }

  Future<void> saveActivityInDatabase() async {
    final db = FirebaseFirestore.instance;
    final String currentTreatmentDatabaseId = currentTreatment!.databaseId!;
    final data = <String, String>{
      TREATMENT_ID_KEY: currentTreatmentDatabaseId,
      ACTIVITY_NAME_KEY: activityNameFormValue.text,
      //ACTIVITY_ACTIVITY_KEY: activityActivityValue ?? "",
      ACTIVITY_TIME_NUMBER_KEY: activityTimeFormValue.text,
      ACTIVITY_TIME_TYPE_KEY: activityDurationFormValue ?? "",
      //ACTIVITY_PERIODICITY_KEY: activityPeriodicityValue ?? "",
      //ACTIVITY_CALORIES_KEY: activityCaloriesValue ?? "",
      //PERMITTED_KEY: editingPermittedActivity ? YES_KEY : NO_KEY
    };

    /*  if (updatePermittedActivity >= 0 || updateNoPermittedActivity >= 0) {
      String? databaseId;
      if (updatePermittedActivity >= 0) {
        databaseId = activitiesList[updatePermittedActivity].databaseId;
      } else {
        databaseId = activitiesNoPermittedList[updateNoPermittedActivity].databaseId;
      }

      db
          .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
          .doc(databaseId)
          .update(data)
          .then((value) => Navigator.pop(context, _currentPage));
    } else { */
    if (editingActivity) {
      String? databaseId = activitiesList[activityIndex].databaseId;
      await db.collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY).doc(databaseId).update(data);
    } else {
      final response = await db.collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY).add(data);
      await saveInPendingList(
          PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY, response.id, currentTreatmentDatabaseId);
    }

    /*  .then((value) =>
          saveInPendingList(
              PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY, value.id, currentTreatmentDatabaseId)); */
    //}
  }

  Future<void> saveMedicationInDatabase() async {
    final db = FirebaseFirestore.instance;
    final String currentTreatmentDatabaseId = currentTreatment!.databaseId!;
    final data = <String, String>{
      TREATMENT_ID_KEY: currentTreatmentDatabaseId,
      MEDICATION_NAME_KEY: medicationNameValue ?? "",
      MEDICATION_START_DATE_KEY: medicationStartDateValue ?? "",
      MEDICATION_DURATION_NUMBER_KEY: medicationDurationNumberValue ?? "",
      MEDICATION_DURATION_TYPE_KEY: medicationDurationTypeValue ?? "",
      MEDICATION_PASTILLE_TYPE_KEY: medicationTypeValue ?? "",
      MEDICATION_DOSE_KEY: medicationDoseValue ?? "",
      MEDICATION_QUANTITY_KEY: medicationQuantityValue ?? "",
      MEDICATION_PERIODICITY_KEY: medicationPeriodicityValue ?? "",
      MEDICATION_RECOMMENDATION_KEY: medicationRecommendationValue ?? ""
    };
    if (updateMedication >= 0) {
      await db
          .collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY)
          .doc(medicationsList[updateMedication].databaseId)
          .update(data);
      //.then((value) => Navigator.pop(context, _currentPage));
    } else {
      final response = await db.collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY).add(data);
      await saveInPendingList(
          PENDING_MEDICATION_PRESCRIPTIONS_COLLECTION_KEY, response.id, currentTreatmentDatabaseId);
      /* .then((value) =>
          saveInPendingList(
              PENDING_MEDICATION_PRESCRIPTIONS_COLLECTION_KEY, value.id, currentTreatmentDatabaseId,
              dontGoBack: dontGoBack)); */
    }
  }

  /*  Future<void> saveNutritionInDatabase(String? foodName, bool isPermitted) async {
    final db = FirebaseFirestore.instance;
    final String currentTreatmentDatabaseId = currentTreatment!.databaseId!;
    final data = <String, String>{
      TREATMENT_ID_KEY: currentTreatmentDatabaseId,
      NUTRITION_NAME_KEY: foodName ?? "",
      //NUTRITION_CARBOHYDRATES_KEY: nutritionCarboValue ?? "",
      //NUTRITION_MAX_CALORIES_KEY: nutritionCaloriesValue ?? "",
      NUTRITION_HEIGHT_KEY: heightValue ?? "",
      NUTRITION_WEIGHT_KEY: weightValue ?? "",
      NUTRITION_IMC_KEY: imcTextController.text,
      PERMITTED_KEY: isPermitted ? YES_KEY : NO_KEY,
    };
    if (updatePermittedFood >= 0 || updateNoPermittedFood >= 0) {
      String? databaseId;
      if (updatePermittedFood >= 0) {
        //Ver cual de la lista hay que modificar.
        databaseId = nutritionList[updatePermittedFood].databaseId;
      } else {
        databaseId = nutritionNoPermittedList[updateNoPermittedFood].databaseId;
      }
      await db.collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY).doc(databaseId).update(data);
      //.then((value) => Navigator.pop(context, _currentPage));
    } else {
      await db.collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY).add(data);
      /* .then((value) =>
          saveInPendingListAndGoBack(PENDING_NUTRITION_PRESCRIPTIONS_COLLECTION_KEY, value.id,
              currentTreatmentDatabaseId)); */
    }
  } */

  void saveEachFoodInDatabase() async {
    if (foodPermitted != null) {
      await saveFoodInDatabase(foodPermitted, true);
    }
    if (foodNotPermitted != null) {
      await saveFoodInDatabase(foodNotPermitted, false);
    }
    if (mounted) {
      Navigator.pop(context, _currentPage);
    }
  }

  //databaseID = FoW5LrG3K132gAYKEdeS
  Future<void> saveFoodInDatabase(String? foodName, bool isPermitted) async {
    final String treatmentId = currentTreatment!.databaseId!;

    final db = FirebaseFirestore.instance;
    final data = makeFoodStructure(foodName, isPermitted, treatmentId);
    var response = await db.collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY).add(data);
    await saveInPendingList(
        PENDING_NUTRITION_PRESCRIPTIONS_COLLECTION_KEY, response.id, treatmentId);
  }

  Future<void> updateFoodInDatabase(String? foodName, bool isPermitted, int index) async {
    //final String treatmentId = currentTreatment!.databaseId!;
    String? databaseid;
    if (isPermitted) {
      databaseid = nutritionList[index].databaseId;
    } else {
      databaseid = nutritionNoPermittedList[index].databaseId;
    }
    //isPermitted ? nutritionNoPermittedList[index].databaseId : nutritionList[index].databaseId;
    final db = FirebaseFirestore.instance;
    final data = {
      NUTRITION_NAME_KEY: foodName ?? "",
      NUTRITION_HEIGHT_KEY: heightController.text,
      NUTRITION_WEIGHT_KEY: weightController.text,
      NUTRITION_IMC_KEY: imcTextController.text,
    };
    await db.collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY).doc(databaseid).update(data);
  }
  //krxDLN2L3HBFlQHw9adS

  Map<String, String> makeFoodStructure(String? foodName, bool isPermitted, String treatmentId) {
    return {
      TREATMENT_ID_KEY: treatmentId,
      NUTRITION_NAME_KEY: foodName ?? "",
      NUTRITION_HEIGHT_KEY: heightController.text,
      NUTRITION_WEIGHT_KEY: weightController.text,
      NUTRITION_IMC_KEY: imcTextController.text,
      PERMITTED_KEY: isPermitted ? YES_KEY : NO_KEY,
    };
  }

  getButtonOrOthersList() {
    return !editingOthers
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingOthers = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar otra prescripción",
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              sizedBox10,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      child: Text(othersNameValue ?? "Nombre",
                          style: const TextStyle(fontSize: 14, color: Color(0xFF999999))))
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                const SizedBox(
                    width: 80,
                    child:
                        Text("Duración", style: TextStyle(fontSize: 14, color: Color(0xFF999999)))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: SizedBox(
                      height: durationError ? 45 : 25,
                      width: 60,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value == '') {
                            setState(() {
                              durationError = true;
                            });
                            return "Complete el campo";
                          }
                          setState(() {
                            durationError = false;
                          });
                          return null;
                        },
                        controller: TextEditingController(text: othersDurationValue),
                        onChanged: (value) {
                          othersDurationValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: staticComponents.getMiddleInputDecoration('-'),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: SizedBox(
                      height: durationError ? 45 : 25,
                      width: 60,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value == '') {
                            setState(() {
                              durationError = true;
                            });
                            return "Complete el campo";
                          }
                          setState(() {
                            durationError = false;
                          });
                          return null;
                        },
                        controller: TextEditingController(text: othersDurationTypeValue),
                        onChanged: (value) {
                          othersDurationTypeValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: "dias",
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                )
              ]),
              sizedBox10,
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                const SizedBox(
                    width: 80,
                    child: Text("Periodicidad",
                        style: TextStyle(fontSize: 14, color: Color(0xFF999999)))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: SizedBox(
                      height: durationError ? 45 : 25,
                      width: 60,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value == '') {
                            setState(() {
                              durationError = true;
                            });
                            return "Complete el campo";
                          }
                          setState(() {
                            durationError = false;
                          });
                          return null;
                        },
                        controller: TextEditingController(text: othersPeriodicityValue),
                        onChanged: (value) {
                          othersPeriodicityValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: staticComponents.getMiddleInputDecoration('-'),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: SizedBox(
                      height: durationError ? 45 : 25,
                      width: 60,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value == '') {
                            setState(() {
                              durationError = true;
                            });
                            return "Complete el campo";
                          }
                          setState(() {
                            durationError = false;
                          });
                          return null;
                        },
                        controller: TextEditingController(text: othersPeriodicityTypeValue),
                        onChanged: (value) {
                          othersPeriodicityTypeValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: "dias",
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                )
              ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Detalle", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              TextFormField(
                validator: (value) {
                  if (value == null || value == '') {
                    setState(() {
                      durationError = true;
                    });
                    return "Complete el campo";
                  }
                  setState(() {
                    durationError = false;
                  });
                  return null;
                },
                controller: TextEditingController(text: othersDetailValue),
                onChanged: (value) {
                  othersDetailValue = value;
                },
                style: const TextStyle(fontSize: 14),
                minLines: 2,
                maxLines: 10,
                textAlignVertical: TextAlignVertical.center,
                decoration: staticComponents.getBigInputDecoration('Agregar texto'),
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Recomendación", style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              TextFormField(
                validator: (value) {
                  if (value == null || value == '') {
                    setState(() {
                      durationError = true;
                    });
                    return "Complete el campo";
                  }
                  setState(() {
                    durationError = false;
                  });
                  return null;
                },
                controller: TextEditingController(text: othersRecommendationValue),
                onChanged: (value) {
                  othersRecommendationValue = value;
                },
                style: const TextStyle(fontSize: 14),
                minLines: 2,
                maxLines: 10,
                textAlignVertical: TextAlignVertical.center,
                decoration: staticComponents.getBigInputDecoration('Agregar texto'),
              ),
            ]));
  }

  Future<void> saveInPendingList(
      String idKey, String prescriptionId, String currentTreatmentDatabaseId,
      {bool dontGoBack = false}) async {
    final db = FirebaseFirestore.instance;
    final data = <String, String>{
      PENDING_PRESCRIPTIONS_ID_KEY: prescriptionId,
      PENDING_PRESCRIPTIONS_TREATMENT_KEY: currentTreatmentDatabaseId,
    };
    await db.collection(idKey).add(data);
    /* .then((value) =>
        dontGoBack ? refreshMedicationPrescription() : Navigator.pop(context, _currentPage)); */
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(21001, 1, 1),
    );

    final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (d != null && time != null) {
      setState(() {
        medicationStartDateValue =
            '${DateFormat('dd - MMM yyyy ').format(d)}${time.hour}:${time.minute}';
      });
    }
  }

  void deleteMedication(int index) {
    final db = FirebaseFirestore.instance;
    db
        .collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY)
        .doc(medicationsList[index].databaseId)
        .delete();
    setState(() {
      medicationsList.removeAt(index);
    });
  }

  void deleteActivity(int index) {
    final db = FirebaseFirestore.instance;
    db
        .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
        .doc(activitiesList[index].databaseId)
        .delete();
    setState(() {
      activitiesList.removeAt(index);
    });
  }

  void deleteNutritionPermitted(int index, bool permitted) {
    String? deleteId;
    if (permitted) {
      deleteId = nutritionList[index].databaseId;
      setState(() {
        nutritionList.removeAt(index);
      });
    } else {
      deleteId = nutritionNoPermittedList[index].databaseId;
      setState(() {
        nutritionNoPermittedList.removeAt(index);
      });
    }
    final db = FirebaseFirestore.instance;
    db.collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY).doc(deleteId).delete();
  }

  void deleteOthers(int index) {
    final db = FirebaseFirestore.instance;
    db.collection(OTHERS_PRESCRIPTION_COLLECTION_KEY).doc(othersList[index].databaseId).delete();
    setState(() {
      othersList.removeAt(index);
    });
  }

  int activityIndex = 0;

  void editActivity(int index) {
    setState(() {
      editingActivity = true;
      addNewActivity = false;
      activityIndex = index;
      fillActivityFormWithValues(index);
      readOnlyActivity = false;
    });
  }

  fillActivityFormWithValues(int index) {
    activityNameFormValue.text = activitiesList[index].name ?? '';
    activityTimeFormValue.text = activitiesList[index].timeNumber ?? '';
    activityDurationFormValue = activitiesList[index].timeType ?? '';
  }

  void editMedication(int index) {
    setState(() {
      //Muestra el formulario
      editingMedication = true;
      //En vez de guardar en db, lo actualiza
      updateMedication = index;
      //Formulario
      fillMedicationFormWithValues(index);

      readOnlyMedication = false;
    });
  }

  void fillMedicationFormWithValues(int index) {
    medicationNameValue = medicationsList[index].name ?? "";
    medicationDurationNumberValue = medicationsList[index].durationNumber ?? "";
    medicationStartDateValue = medicationsList[index].startDate ?? "";
    medicationDoseValue = medicationsList[index].dose ?? "";
    medicationRecommendationValue = medicationsList[index].recomendation ?? "";
    if (isNotEmpty(medicationsList[index].durationType)) {
      medicationDurationTypeValue = medicationsList[index].durationType;
    }
    if (isNotEmpty(medicationsList[index].pastilleType)) {
      medicationTypeValue = medicationsList[index].pastilleType;
    }
    if (isNotEmpty(medicationsList[index].quantity)) {
      medicationQuantityValue = medicationsList[index].quantity;
    }
    if (isNotEmpty(medicationsList[index].periodicity)) {
      medicationPeriodicityValue = medicationsList[index].periodicity;
    }
  }

  void editFood(int index, bool permitted) {
    setState(() {
      editingPermittedFood = permitted;
      if (editingPermittedFood) {
        updatePermittedFood = index;
        nutritionNameValue = nutritionList[index].name ?? "";
        nutritionCarboValue = nutritionList[index].carbohydrates ?? "";
        nutritionCaloriesValue = nutritionList[index].maxCalories ?? "";
      } else {
        updateNoPermittedFood = index;
        nutritionNameValue = nutritionNoPermittedList[index].name ?? "";
        nutritionCarboValue = nutritionNoPermittedList[index].carbohydrates ?? "";
        nutritionCaloriesValue = nutritionNoPermittedList[index].maxCalories ?? "";
      }
    });
  }

  /*  void editActivity(int index, bool permitted) {
    setState(() {
      editingPermittedActivity = permitted;
      if (editingPermittedActivity) {
        updatePermittedActivity = index;
        activityNameValue = activitiesList[index].name ?? "";
        activityActivityValue = activitiesList[index].activity ?? "";
        activityTimeNumberValue = activitiesList[index].timeNumber ?? "";
        activityCaloriesValue = activitiesList[index].calories ?? "";
        if (isNotEmpty(activitiesList[index].periodicity)) {
          activityPeriodicityValue = activitiesList[index].periodicity;
        }
        if (isNotEmpty(activitiesList[index].timeType)) {
          activityTimeTypeValue = activitiesList[index].timeType;
        }
      } else {
        updateNoPermittedActivity = index;
        activityNameValue = activitiesNoPermittedList[index].name ?? "";
        activityActivityValue = activitiesNoPermittedList[index].activity ?? "";
        activityTimeNumberValue = activitiesNoPermittedList[index].timeNumber ?? "";
        activityCaloriesValue = activitiesNoPermittedList[index].calories ?? "";
        if (isNotEmpty(activitiesNoPermittedList[index].periodicity)) {
          activityPeriodicityValue = activitiesNoPermittedList[index].periodicity;
        }
        if (isNotEmpty(activitiesNoPermittedList[index].timeType)) {
          activityTimeTypeValue = activitiesNoPermittedList[index].timeType;
        }
      }
    });
  } */

  void editOthers(int index) {
    setState(() {
      editingOthers = true;
      updateOthers = index;
      othersNameValue = othersList[index].name ?? "";
      othersDurationValue = othersList[index].duration ?? "";
      othersPeriodicityValue = othersList[index].periodicity ?? "";
      othersDetailValue = othersList[index].detail ?? "";
      othersRecommendationValue = othersList[index].recommendation ?? "";
    });
  }

  /* void deleteActivity(int index, bool permitted) {
    String? deleteId;
    if (permitted) {
      deleteId = activitiesList[index].databaseId;
      setState(() {
        activitiesList.removeAt(index);
      });
    } else {
      deleteId = activitiesNoPermittedList[index].databaseId;
      setState(() {
        activitiesNoPermittedList.removeAt(index);
      });
    }
    final db = FirebaseFirestore.instance;
    db.collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY).doc(deleteId).delete();
  } */

  void _calculateIMC(String value) {
    double height = double.parse(heightController.text.isEmpty ? '0.0' : heightController.text);
    double weight = double.parse(weightController.text.isEmpty ? '0.0' : weightController.text);
    if (height != 0.0 && weight != 0.0) {
      imcTextController.text = (weight / (pow(height, 2))).toString();
    }
  }
}

class DisableWidget extends StatelessWidget {
  const DisableWidget({Key? key, this.isDisable = false, required this.child}) : super(key: key);

  final bool isDisable;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: isDisable, child: Opacity(opacity: isDisable ? 0.5 : 1, child: child));
  }
}
