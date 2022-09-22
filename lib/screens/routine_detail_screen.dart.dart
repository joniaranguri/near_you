import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:near_you/common/survey_static_values.dart';
import 'package:intl/intl.dart';

import '../Constants.dart';
import '../model/activityPrescription.dart';
import '../model/medicationPrescription.dart';
import '../model/nutritionPrescription.dart';
import '../model/othersPrescription.dart';
import '../widgets/firebase_utils.dart';
import '../widgets/static_components.dart';

class RoutineDetailScreen extends StatefulWidget {
  String currentTreatmentId;

  RoutineDetailScreen(this.currentTreatmentId);

  static const routeName = '/routine_detail';

  @override
  _RoutineDetailScreenState createState() =>
      _RoutineDetailScreenState(currentTreatmentId);
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late final Future<List<MedicationPrescription>> medicationPrescriptionFuture;
  late final Future<List<NutritionPrescription>> nutritionPrescriptionFuture;
  late final Future<List<ActivityPrescription>> activityPrescriptionFuture;
  late final Future<List<OthersPrescription>> othersPrescriptionFuture;

  List<MedicationPrescription> medicationsList = <MedicationPrescription>[];
  List<NutritionPrescription> nutritionList = <NutritionPrescription>[];
  List<ActivityPrescription> activitiesList = <ActivityPrescription>[];
  List<NutritionPrescription> nutritionNoPermittedList =
      <NutritionPrescription>[];
  List<ActivityPrescription> activitiesNoPermittedList =
      <ActivityPrescription>[];
  List<OthersPrescription> othersList = <OthersPrescription>[];
  var currentRoutineIndex = 0;
  int totalPrescriptions = 0;
  double percentageProgress = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  static StaticComponents staticComponents = StaticComponents();

  String currentTreatmentId;

  String? examsGlucosaLevelValue;

  _RoutineDetailScreenState(this.currentTreatmentId);

  get sizedBox10 => const SizedBox(height: 10);

  @override
  void initState() {
    medicationPrescriptionFuture =
        getMedicationPrescriptions(currentTreatmentId);
    activityPrescriptionFuture = getActivityPrescriptions(currentTreatmentId);
    nutritionPrescriptionFuture = getNutritionPrescriptions(currentTreatmentId);
    othersPrescriptionFuture = getOthersPrescriptions(currentTreatmentId);
    medicationPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                medicationsList = value;
                totalPrescriptions = getTotalPrescriptionsSize();
              })
            }
        });
    nutritionPrescriptionFuture.then((value) => {
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
                  totalPrescriptions = getTotalPrescriptionsSize();
                }
              })
            }
        });
    activityPrescriptionFuture.then((value) => {
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
                  totalPrescriptions = getTotalPrescriptionsSize();
                }
              })
            }
        });
    othersPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                othersList = value;
                totalPrescriptions = getTotalPrescriptionsSize();
              })
            }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Stack(children: <Widget>[
      Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(screenHeight / 10),
            // here the desired height
            child: AppBar(
              toolbarHeight: screenHeight / 10,
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Text(getAppbarTitle(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )),
        body: Stack(children: <Widget>[
          Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: FittedBox(
                fit: BoxFit.none,
                child: SvgPicture.asset('assets/images/backgroundHome.svg'),
              )),
          Scaffold(
              backgroundColor: Colors.transparent,
              body: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_month,
                                      color: Color(0xff999999)),
                                  Text(
                                      DateFormat(' dd - MMM yyyy hh:mm:ss')
                                          .format(DateTime.now()),
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xff999999)))
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                  color: Color(0xffCECECE),
                                  thickness: 1,
                                ))
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      icon: SvgPicture.asset(
                                        (currentRoutineIndex == 0
                                            ? 'assets/images/medication_selected.svg'
                                            : 'assets/images/medication_unselected.svg'),
                                        height: 44,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 0;
                                        });
                                      }),
                                  IconButton(
                                      padding: const EdgeInsets.all(5),
                                      icon: SvgPicture.asset(
                                        (currentRoutineIndex == 1
                                            ? 'assets/images/nutrition_selected.svg'
                                            : 'assets/images/nutrition_unselected.svg'),
                                        height: 44,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 1;
                                        });
                                      }),
                                  IconButton(
                                      padding: const EdgeInsets.all(5),
                                      icon: SvgPicture.asset(
                                          (currentRoutineIndex == 2
                                              ? 'assets/images/activity_selected.svg'
                                              : 'assets/images/activity_unselected.svg'),
                                          height: 44),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 2;
                                        });
                                      }),
                                  IconButton(
                                      padding: const EdgeInsets.all(5),
                                      icon: SvgPicture.asset(
                                        (currentRoutineIndex == 3
                                            ? 'assets/images/exams_selected.svg'
                                            : 'assets/images/exams_unselected.svg'),
                                        height: 44,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 3;
                                        });
                                      })
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            FutureBuilder(
                              future: medicationPrescriptionFuture,
                              builder: (context, AsyncSnapshot snapshot) {
                                //patientUser = user.User.fromSnapshot(snapshot.data);
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (totalPrescriptions == 0) {
                                    return getEmptyView();
                                  }
                                  return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        GFProgressBar(
                                          percentage: percentageProgress,
                                          lineHeight: 17,
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              (100 * percentageProgress)
                                                      .toInt()
                                                      .toString() +
                                                  '%',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          backgroundColor: Color(0xffD9D9D9),
                                          progressBarColor: Color(0xff2F8F9D),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: screenHeight * 0.55,
                                          child: getCurrrentSectionList(),
                                        )
                                      ]);
                                  //  return getScreenType();
                                }
                                return CircularProgressIndicator();
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  (currentRoutineIndex < 3
                                      ? FlatButton(
                                          disabledColor: Color(0xffD9D9D9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          color: const Color(0xff2F8F9D),
                                          textColor: Colors.white,
                                          onPressed: () {
                                            nextRoutine();
                                          },
                                          child: const Text(
                                            'Siguiente',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        )),
                                  (currentRoutineIndex > 0
                                      ? FlatButton(
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  color: Color(0xff9D9CB5),
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          textColor: Color(0xff9D9CB5),
                                          onPressed: () {
                                            previousRoutine();
                                          },
                                          child: const Text(
                                            'Anterior',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        )),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ))
        ]),
      )
    ]);
  }

  /*Future<List<RoutineDetailData>> getRoutineDetailQuestions() async {
    return StaticRoutineDetail.RoutineDetailStaticList;
  }
*/

  void saveAndGoBack() {
    /*  final db = FirebaseFirestore.instance;
    final data = <String, String>{};
    for (int i = 0; i < RoutineDetailResults.length; i++) {
      data.putIfAbsent((i + 1).toString(), () => RoutineDetailResults[i]!);
    }
    db
        .collection(USERS_COLLECTION_KEY)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(RoutineDetailS_COLLECTION_KEY)
        .add(data)
        .then((value) => dialogSuccess());*/
  }

  Widget getEmptyView() {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.55,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset('assets/images/no_routine_icon.svg'),
                SizedBox(height: 5),
                Text(
                  '¡Usted no presenta\nprescripción en esta sección!',
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff999999),
                    fontFamily: 'Italic',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ])),
    );
  }

  void nextRoutine() {
    setState(() {
      ++currentRoutineIndex;
    });
  }

  void previousRoutine() {
    setState(() {
      --currentRoutineIndex;
    });
  }

  Widget getCurrrentSectionList() {
    switch (currentRoutineIndex) {
      case 0:
        return getMedicationList();
      case 1:
        return getNutritionsLists();
      case 2:
        return getActivityList();
      default:
        return getExamsList();
    }
  }

  Widget getMedicationList() {
    if (medicationsList.isEmpty) {
      return getEmptyView();
    }
    return SizedBox(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medicationsList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("${index + 1}°Medicamento",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff2F8F9D),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                              color: Color(0xffCECECE),
                              thickness: 1,
                            ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: 35,
                              child: Text(
                                  medicationsList[index].name ?? "Nombre",
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff999999))),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                int value = medicationsList[index].state ?? 0;
                                int newValue = value == 0 ? 1 : 0;
                                setState(() {
                                  medicationsList[index].state = newValue;
                                  updatePercentageProgress();
                                });
                              },
                              color: (medicationsList[index].state ?? 0) == 0
                                  ? Colors.white
                                  : const Color(0xff3BACB6),
                              child: Text(
                                'Listo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (medicationsList[index].state ?? 0) == 0
                                          ? const Color(0xff2F8F9D)
                                          : Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: SizedBox(
                                    height: 35,
                                    width: 172,
                                    child: Text("Periodicidad",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF999999)))),
                              ),
                              Flexible(
                                  child: SizedBox(
                                      height: 25,
                                      width: screenWidth * 0.4,
                                      child: TextFormField(
                                        controller: TextEditingController(
                                            text: medicationsList[index]
                                                .periodicity),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)),
                                        decoration: staticComponents
                                            .getMiddleInputDecorationDisabledRoutine(),
                                      )))
                            ]),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Recomendación",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff999999)))
                          ],
                        ),
                        sizedBox10,
                        TextFormField(
                          controller: TextEditingController(
                              text: medicationsList[index].recomendation),
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xff999999)),
                          minLines: 2,
                          maxLines: 10,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: staticComponents
                              .getBigInputDecorationDisabledRoutine(),
                        ),
                        sizedBox10
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getNutritionList() {
    return SizedBox(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nutritionList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${index + 1}.¿Hoy consumiste tu porción de\n ${nutritionList[index].name} diaria?",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff808080)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 1,
                                          groupValue:
                                              nutritionList[index].state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionList[index].state =
                                                  value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'Si',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 0,
                                          groupValue:
                                              nutritionList[index].state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionList[index].state =
                                                  value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                )
                              ]),
                        )
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getNutritionListProhibited() {
    return SizedBox(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nutritionNoPermittedList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${index + 1}.¿Hoy consumiste \n ${nutritionNoPermittedList[index].name}?",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff808080)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 1,
                                          groupValue:
                                              nutritionNoPermittedList[index]
                                                  .state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionNoPermittedList[index]
                                                  .state = value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'Si',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 0,
                                          groupValue:
                                              nutritionNoPermittedList[index]
                                                  .state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionNoPermittedList[index]
                                                  .state = value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                )
                              ]),
                        )
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getActivityList() {
    if (activitiesList.isEmpty) {
      return getEmptyView();
    }
    return SizedBox(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activitiesList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("${index + 1}° Actividad",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff2F8F9D),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                              color: Color(0xffCECECE),
                              thickness: 1,
                            ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: 35,
                              child: Text(
                                  activitiesList[index].name ?? "Nombre",
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff999999))),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                int value = activitiesList[index].state ?? 0;
                                int newValue = value == 0 ? 1 : 0;
                                setState(() {
                                  activitiesList[index].state = newValue;
                                  updatePercentageProgress();
                                });
                              },
                              color: (activitiesList[index].state ?? 0) == 0
                                  ? Colors.white
                                  : const Color(0xff3BACB6),
                              child: Text(
                                'Listo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (activitiesList[index].state ?? 0) == 0
                                      ? const Color(0xff2F8F9D)
                                      : Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: SizedBox(
                                    height: 35,
                                    width: 172,
                                    child: Text("Tiempo",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF999999)))),
                              ),
                              Flexible(
                                  child: SizedBox(
                                      height: 25,
                                      width: screenWidth * 0.27,
                                      child: TextFormField(
                                        controller: TextEditingController(
                                            text: activitiesList[index]
                                                .timeNumber),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)),
                                        decoration: staticComponents
                                            .getMiddleInputDecorationDisabledRoutine(),
                                      ))),
                              Flexible(
                                  child: SizedBox(
                                      height: 25,
                                      width: screenWidth * 0.27,
                                      child: TextFormField(
                                        controller: TextEditingController(
                                            text:
                                                activitiesList[index].timeType),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)),
                                        decoration: staticComponents
                                            .getMiddleInputDecorationDisabledRoutine(),
                                      )))
                            ])
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getExamsList() {
    if (othersList.isEmpty) {
      return getEmptyView();
    }
    return Column(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Column(
                children: [
                  Text(
                    "¿Cuanto fue tu nivel de glucosa el día de hoy?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xff808080)),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                              child: SizedBox(
                                  height: 25,
                                  width: screenWidth * 0.2,
                                  child: TextFormField(
                                    controller: TextEditingController(
                                        text: examsGlucosaLevelValue),
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xff999999)),
                                    decoration: staticComponents
                                        .getMiddleInputDecoration("3"),
                                  ))),
                          Flexible(
                            child: SizedBox(
                                height: 25,
                                child: Text("mg/dl",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF999999)))),
                          )
                        ]),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lista de exámenes:",
                style: TextStyle(color: Color(0xff999999), fontSize: 14))
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: othersList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "¿Pasaste tu examen de tolerancia oral a la glucosa?",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xff808080)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                              value: 1,
                                              groupValue:
                                                  othersList[index].state,
                                              onChanged: (value) {
                                                setState(() {
                                                  othersList[index].state =
                                                      value!;
                                                  updatePercentageProgress();
                                                });
                                              }),
                                          Expanded(
                                            child: Text(
                                              'Si',
                                              style: TextStyle(
                                                  color: Color(0xff67757F),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                              value: 0,
                                              groupValue:
                                                  othersList[index].state,
                                              onChanged: (value) {
                                                setState(() {
                                                  othersList[index].state =
                                                      value!;
                                                  updatePercentageProgress();
                                                });
                                              }),
                                          Expanded(
                                            child: Text(
                                              'No',
                                              style: TextStyle(
                                                  color: Color(0xff67757F),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      flex: 1,
                                    )
                                  ]),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }))
      ],
    );
  }

  String getAppbarTitle() {
    switch (currentRoutineIndex) {
      case 0:
        return 'Medicación';
      case 1:
        return 'Alimentación';
      case 2:
        return 'Actividad Física';
      default:
        return 'Exámenes';
    }
  }

  void updatePercentageProgress() {
    int total = medicationsList.length +
        activitiesList.length +
        nutritionNoPermittedList.length +
        nutritionList.length +
        othersList.length;
    int medicationCompleted = 0;
    int activityCompleted = 0;
    int nutritionCompleted = 0;
    int othersCompleted = 0;
    final data = <String, Object>{};
    for (var element in medicationsList) {
      medicationCompleted += element.state ?? 0;
      if (element.name != null) {
        data.addAll({element.name!: element.state ?? 0});
      }
    }
    for (var element in activitiesList) {
      activityCompleted += element.state ?? 0;
      if (element.name != null) {
        data.addAll({element.name!: element.state ?? 0});
      }
    }
    for (var element in nutritionList) {
      if (element.state != null) nutritionCompleted++;
      if (element.name != null) {
        data.addAll({element.name!: element.state ?? 0});
      }
    }
    for (var element in nutritionNoPermittedList) {
      if (element.state != null) nutritionCompleted++;
      if (element.name != null) {
        data.addAll({element.name!: element.state ?? 0});
      }
    }
    for (var element in othersList) {
      if (element.state != null) othersCompleted++;
      if (element.name != null) {
        data.addAll({element.name!: element.state ?? 0});
      }
    }
    int currentCompleted = medicationCompleted +
        nutritionCompleted +
        othersCompleted +
        activityCompleted;
    percentageProgress = currentCompleted / total;
    data.addAll({ROUTINE_TOTAL_PERCENTAGE_KEY: percentageProgress});
    saveResultsInDatabase(data, medicationCompleted, nutritionCompleted,
        activityCompleted, othersCompleted);
  }

  Widget getNutritionsLists() {
    if (nutritionList.isEmpty && nutritionNoPermittedList.isEmpty) {
      return getEmptyView();
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alimentos permitidos",
              style: TextStyle(color: Color(0xff999999), fontSize: 14),
            )
          ],
        ),
        SizedBox(height: 10),
        getNutritionList(),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Alimentos no permitidos",
                style: TextStyle(color: Color(0xff999999), fontSize: 14))
          ],
        ),
        SizedBox(height: 10),
        getNutritionListProhibited()
      ],
    );
  }

  void saveResultsInDatabase(
      Map<String, Object> data,
      int medicationCompleted,
      int nutritionCompleted,
      int activityCompleted,
      int othersCompleted) async {
    final db = FirebaseFirestore.instance;
    String todayFormattedDate =
        DateFormat('dd-MMM-yyyy').format(DateTime.now());
    final int medicationListSize = medicationsList.length;
    final int activitiesListSize = activitiesList.length;
    final int nutritionsListSize =
        nutritionList.length + nutritionNoPermittedList.length;
    final int examsListSize = othersList.length;
    data.addAll({
      ROUTINE_MEDICATION_PERCENTAGE_KEY:
          medicationListSize > 0 ? medicationCompleted / medicationListSize : 0,
      ROUTINE_ACTIVITY_PERCENTAGE_KEY:
          activitiesListSize > 0 ? activityCompleted / activitiesListSize : 0,
      ROUTINE_NUTRITION_PERCENTAGE_KEY:
          nutritionsListSize > 0 ? nutritionCompleted / nutritionsListSize : 0,
      ROUTINE_EXAMS_PERCENTAGE_KEY:
          examsListSize > 0 ? othersCompleted / examsListSize : 0,
      ROUTINE_HOUR_COMPLETED_KEY: DateFormat('hh:mm').format(DateTime.now())
    });
    db
        .collection(ROUTINES_COLLECTION_KEY)
        .doc(currentTreatmentId) // TODO: add currentTreatmentId when created
        .collection(ROUTINES_RESULTS_KEY)
        .doc(todayFormattedDate)
        .set(data);
  }

  int getTotalPrescriptionsSize() {
    return medicationsList.length +
        activitiesList.length +
        nutritionList.length +
        nutritionNoPermittedList.length +
        othersList.length;
  }
}