import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/screens/add_treatment_screen.dart';
import 'package:near_you/screens/home_screen.dart';
import 'package:near_you/screens/patient_detail_screen.dart';
import 'package:near_you/screens/visualize_prescription_screen.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../model/user.dart' as user;
import '../widgets/grouped_bar_chart.dart';

class PatientDetail extends StatefulWidget {
  final bool isDoctorView;
  user.User? detailedUser;

  PatientDetail(this.detailedUser, {required this.isDoctorView});

  factory PatientDetail.forDoctorView(user.User? paramUser) {
    return PatientDetail(
      paramUser,
      isDoctorView: true,
    );
  }

  factory PatientDetail.forPatientView(user.User? paramUser) {
    return PatientDetail(
      paramUser,
      isDoctorView: false,
    );
  }

  @override
  PatientDetailState createState() =>
      PatientDetailState(this.detailedUser, this.isDoctorView);
}

class PatientDetailState extends State<PatientDetail> {
  static StaticComponents staticComponents = StaticComponents();
  user.User? detailedUser;
  Treatment? currentTreatment;
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  bool isDoctorView;
  late final Future<Treatment> currentTreatmentFuture;
  late final Future<List<String>> medicationFuture;
  late final Future<List<String>> activityFuture;
  late final Future<List<String>> nutritionFuture;
  late final Future<List<String>> othersFuture;
  int medicationCounter = 0;
  int activityCounter = 0;
  int nutritionCounter = 0;
  int othersCounter = 0;

  String? durationTypeValue;
  String? durationValue;
  String? stateValue;
  String? descriptionValue;
  String? startDateValue;
  String? endDateValue;
  List<String> medicationsList = <String>[];
  List<String> nutritionList = <String>[];
  List<String> activitiesList = <String>[];
  List<String> othersList = <String>[];

  PatientDetailState(this.detailedUser, this.isDoctorView);

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
                color: Color(0xffCCD6DD),
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle),
          ),
        ),
      ));

  @override
  void initState() {
    currentTreatmentFuture =
        getCurrentTReatmentById(detailedUser!.currentTreatment!);
    medicationFuture =
        getMedicationPrescriptions(detailedUser!.currentTreatment!);
    activityFuture = getActivityPrescriptions(detailedUser!.currentTreatment!);
    nutritionFuture =
        getNutritionPrescriptions(detailedUser!.currentTreatment!);
    othersFuture = getOthersPrescriptions(detailedUser!.currentTreatment!);
    currentTreatmentFuture.then((value) => {
          setState(() {
            currentTreatment = value;
            durationTypeValue = currentTreatment!.durationType;
            durationValue = currentTreatment!.durationNumber;
            stateValue = currentTreatment!.state;
            descriptionValue = currentTreatment!.description;
            startDateValue = currentTreatment!.startDate;
            endDateValue = currentTreatment!.endDate;
          })
        });
    medicationFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                medicationsList = value;
                if (value.isNotEmpty) medicationCounter = 1;
              })
            }
        });

    activityFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                activitiesList = value;
                if (value.isNotEmpty) activityCounter = 1;
              })
            }
        });

    nutritionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                nutritionList = value;
                if (value.isNotEmpty) nutritionCounter = 1;
              })
            }
        });

    othersFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                othersList = value;
                if (value.isNotEmpty) othersCounter = 1;
              })
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 580,
      width: screenWidth,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: 3,
          itemBuilder: (ctx, i) => getCurrentPageByIndex(ctx, i)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  getCurrentPageByIndex(BuildContext ctx, int i) {
    switch (i) {
      case 0:
        return getAdherencePage();
      case 1:
        return getCurrentTreatment();
      case 2:
        return getTreatmentHistory();
    }
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
          child: SingleChildScrollView(
              child: ConstrainedBox(
                  child: Column(
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.arrow_back,
                                        color: Color(0xff2F8F9D)),
                                    onPressed: () {
                                      goBack();
                                    },
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 40, right: 40),
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
                                    icon: Icon(Icons.arrow_forward,
                                        color: Color(0xff2F8F9D)),
                                    onPressed: () {
                                      goAhead();
                                    },
                                  )
                                ]),
                            Transform.scale(
                                scale: 0.9,
                                child: Material(
                                    elevation: 10,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                    child: CircularPercentIndicator(
                                        backgroundColor: Colors.white,
                                        radius: 100,
                                        lineWidth: 15,
                                        percent: 0.8,
                                        center: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ShaderMask(
                                              blendMode: BlendMode.srcIn,
                                              shaderCallback: (bounds) =>
                                                  LinearGradient(
                                                          colors:
                                                              getGradientColors(
                                                                  80))
                                                      .createShader(
                                                Rect.fromLTRB(
                                                    0,
                                                    0,
                                                    bounds.width,
                                                    bounds.height),
                                              ),
                                              child: const Text("80" + "%",
                                                  style: TextStyle(
                                                      fontSize: 42,
                                                      fontWeight:
                                                          FontWeight.w900)),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              'RIESGO DE\nABANDONO',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff666666)),
                                            )
                                          ],
                                        ),
                                        linearGradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: getGradientColors(80)),
                                        rotateLinearGradient: true,
                                        circularStrokeCap:
                                            CircularStrokeCap.round))),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              getAdherenceMessage(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff999999),
                              ),
                            )
                          ]),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const <Widget>[
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
                                'Adherencia',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xffCECECE),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20, left: 2),
                              //apply padding to all four sides
                              child: Text(
                                '53%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xffF8191E),
                                ),
                              ),
                            )
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
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
                                'Diario',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Color(0xff3BACB6),
                                    width: 1,
                                    style: BorderStyle.solid),
                              ),
                              height: 20,
                              color:
                                  true ? Colors.white : const Color(0xff3BACB6),
                              textColor:
                                  true ? Color(0xff999999) : Colors.white,
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
                                side: const BorderSide(
                                    color: Color(0xff3BACB6),
                                    width: 1,
                                    style: BorderStyle.solid),
                              ),
                              height: 20,
                              color:
                                  true ? Colors.white : const Color(0xff3BACB6),
                              textColor:
                                  true ? Color(0xff999999) : Colors.white,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              child: const Text(
                                'Mensual',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 2),
                              //apply padding to all four sides
                              child: Text(
                                'Adherencia de Hoy',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff2F8F9D),
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 30, left: 2),
                                //apply padding to all four sides
                                child: Text(
                                  '53%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xffF8191E),
                                  ),
                                ))
                          ]),
                      Container(
                          height: 150, child: GroupedBarChart.withSampleData()),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 2),
                              child: Text(
                                'Cumplimiento de rutinas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff999999),
                                ),
                              ),
                            )
                          ]),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                          height: 86,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Color(0xFFEBE3E3), width: 1),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            10) //         <--- border radius here
                                        ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Medicación",
                                          style: TextStyle(
                                              color: Color(0xff797979),
                                              fontWeight: FontWeight.bold)),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                                        colors:
                                                            getGradientColors(
                                                                50, true))
                                                    .createShader(
                                              Rect.fromLTRB(0, 0, bounds.width,
                                                  bounds.height),
                                            ),
                                            child: const Text("50" + "%",
                                                style: TextStyle(
                                                    fontSize: 42,
                                                    fontWeight:
                                                        FontWeight.w900)),
                                          ),
                                          SizedBox(
                                              height: 30,
                                              child: getColoredTriangle(50.0))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Color(0xFFEBE3E3), width: 1),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            10) //         <--- border radius here
                                        ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Alimentación",
                                        style: TextStyle(
                                            color: Color(0xff797979),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                                        colors:
                                                            getGradientColors(
                                                                86, true))
                                                    .createShader(
                                              Rect.fromLTRB(0, 0, bounds.width,
                                                  bounds.height),
                                            ),
                                            child: const Text("86" + "%",
                                                style: TextStyle(
                                                    fontSize: 42,
                                                    fontWeight:
                                                        FontWeight.w900)),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: getColoredTriangle(86.0),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                          height: 86,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Color(0xFFEBE3E3), width: 1),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            10) //         <--- border radius here
                                        ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Actividad Física",
                                          style: TextStyle(
                                              color: Color(0xff797979),
                                              fontWeight: FontWeight.bold)),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                                        colors:
                                                            getGradientColors(
                                                                95, true))
                                                    .createShader(
                                              Rect.fromLTRB(0, 0, bounds.width,
                                                  bounds.height),
                                            ),
                                            child: const Text("95" + "%",
                                                style: TextStyle(
                                                    fontSize: 42,
                                                    fontWeight:
                                                        FontWeight.w900)),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: getColoredTriangle(95.0),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Color(0xFFEBE3E3), width: 1),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            10) //         <--- border radius here
                                        ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Exáenes",
                                        style: TextStyle(
                                            color: Color(0xff797979),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                                        colors:
                                                            getGradientColors(
                                                                20, true))
                                                    .createShader(
                                              Rect.fromLTRB(0, 0, bounds.width,
                                                  bounds.height),
                                            ),
                                            child: const Text("20" + "%",
                                                style: TextStyle(
                                                    fontSize: 42,
                                                    fontWeight:
                                                        FontWeight.w900)),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: getColoredTriangle(20.0),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            blueIndicator,
                            grayIndicator,
                            grayIndicator
                          ]),
                      //SizedBox
                    ],
                  ),
                  constraints: BoxConstraints(
                    minHeight: 200,
                  ))), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getCurrentTreatment() {
    return FutureBuilder(
        future: currentTreatmentFuture,
        builder: (context, AsyncSnapshot<Treatment> snapshot) {
          if (!snapshot.hasData && isNotEmpty(detailedUser!.currentTreatment)) {
            return Center(child: CircularProgressIndicator());
          } else {
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
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.arrow_back,
                                        color: Color(0xff2F8F9D)),
                                    onPressed: () {
                                      goBack();
                                    },
                                  ),
                                  const Text(
                                    'Tratamiento Actual',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2F8F9D),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward,
                                        color: Color(0xff2F8F9D)),
                                    onPressed: () {
                                      goAhead();
                                    },
                                  )
                                ]),
                            const SizedBox(
                              height: 10,
                            ),
                            getCurrentTreatmentOrEmptyState()
                          ]),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            grayIndicator,
                            blueIndicator,
                            grayIndicator
                          ]),

                      //SizedBox
                    ],
                  ), //Column
                ), //Padding
              ), //SizedBox
            );
          }
        });
  }

  getTreatmentHistory() {
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
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: Color(0xff2F8F9D)),
                            onPressed: () {
                              goBack();
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            //apply padding to all four sides
                            child: Text(
                              'Historial del Tratamiento',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2F8F9D),
                              ),
                            ),
                          ),
                        ]),
                    //TODO: to review later
                    SizedBox(
                      height: 470,
                      //  child: ListViewHomeLayout()
                    )
                  ]),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    grayIndicator,
                    grayIndicator,
                    blueIndicator
                  ]),

              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getTreatmentButtons() {
    return isDoctorView
        ? Container(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
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
                          onPressed: () {
                            goToAddTreatment(false);
                          },
                          child: const Text(
                            'Agregar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      FlatButton(
                        height: 27,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5),
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(30)),
                        textColor: const Color(0xff9D9CB5),
                        onPressed: () {
                          goToAddTreatment(true);
                        },
                        child: const Text(
                          'Actualizar',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 27,
                          child: FlatButton(
                            height: 27,
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(30)),
                            textColor: const Color(0xff9D9CB5),
                            onPressed: () {
                              deleteCurrentTreatment();
                            },
                            child: const Text(
                              'Eliminar',
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
        : SizedBox(height: 0);
  }

  getCurrentTreatmentOrEmptyState() {
    var hasCurrentTreatment = isNotEmpty(detailedUser?.currentTreatment);
    bool isPatient = !isDoctorView;
    if (hasCurrentTreatment) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        width: double.infinity,
        height: 470,
        child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 200,
                ),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(
                                  top: 5, left: 15, right: 15, bottom: 5),
                              decoration: BoxDecoration(
                                  color: const Color(0xff9D9CB5),
                                  border: Border.all(
                                      width: 1, color: const Color(0xff9D9CB5)),
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle),
                              child: Text(
                                "ID Tratamiento",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              )),
                          Container(
                              padding: EdgeInsets.only(
                                  top: 5, left: 15, right: 15, bottom: 5),
                              decoration: BoxDecoration(
                                  color: const Color(0xff2F8F9D),
                                  border: Border.all(
                                      width: 1, color: const Color(0xff2F8F9D)),
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle),
                              child: Text(
                                "#T00003",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ))
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fecha de inicio",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        height: 35,
                        child: TextField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: startDateValue),
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)),
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: IconButton(
                                padding: EdgeInsets.only(bottom: 5),
                                onPressed: () {},
                                icon: const Icon(Icons.calendar_today_outlined,
                                    color: Color(
                                        0xff999999)), // myIcon is a 48px-wide widget.
                              ),
                              fillColor: Color(0xffF1F1F1),
                              hintText: '18 - Jul 2022  15:00',
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Color(0xff999999)),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: staticComponents.littleInputBorder,
                              border: staticComponents.littleInputBorder,
                              focusedBorder:
                                  staticComponents.littleInputBorder),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fecha de fin",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        height: 35,
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: endDateValue),
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)),
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: IconButton(
                                padding: EdgeInsets.only(bottom: 5),
                                onPressed: () {},
                                icon: const Icon(Icons.calendar_today_outlined,
                                    color: Color(
                                        0xff999999)), // myIcon is a 48px-wide widget.
                              ),
                              fillColor: Color(0xffF1F1F1),
                              hintText: '18 - Jul 2022  15:00',
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Color(0xff999999)),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: staticComponents.littleInputBorder,
                              border: staticComponents.littleInputBorder,
                              focusedBorder:
                                  staticComponents.littleInputBorder),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Duración",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        height: 35,
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: currentTreatment != null
                                  ? '${durationValue} ${durationTypeValue}'
                                  : ''),
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF999999)),
                          decoration:
                              staticComponents.getLittleInputDecoration(''),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Estado",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        height: 35,
                        child: TextField(
                          controller: TextEditingController(text: stateValue),
                          readOnly: true,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF999999)),
                          decoration: staticComponents
                              .getLittleInputDecoration('Activo'),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Descripción 1/1",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      minLines: 1,
                      maxLines: 10,
                      readOnly: true,
                      controller: TextEditingController(text: descriptionValue),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF999999)),
                      decoration: staticComponents.getLittleInputDecoration(
                          'Tratamiento de de la diabetes\n con 6 meses de pre...'),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    medicationCounter +
                                activityCounter +
                                nutritionCounter +
                                othersCounter >
                            0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(
                                        top: 5, left: 15, right: 15, bottom: 5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff9D9CB5),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xff9D9CB5)),
                                        borderRadius: BorderRadius.circular(5),
                                        shape: BoxShape.rectangle),
                                    child: Text(
                                      "Prescripciones",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                    ))
                              ])
                        : SizedBox(
                            height: 0,
                          ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Prescripción ${medicationCounter + activityCounter + nutritionCounter + othersCounter}/4",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color(0xff2F8F9D),
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                    getMedicationTreatmentCard(),
                    getNutritionTreatmentCard(),
                    getActivityTreatmentCard(),
                    getOtherTreatmentCard(),
                    getTreatmentButtons()
                  ],
                ))),
      );
    } else {
      return getEmptyStateCard(
          'Aún no se tiene un\n tratamiento actual creado\n para este paciente. Haga\n click en agregar',
          !isPatient);
    }
  }

  getMedicationTreatmentCard() {
    return FutureBuilder(
      future: medicationFuture,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (medicationsList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 0),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Medicación",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        medicationsList.length >
                                                                3
                                                            ? 3
                                                            : medicationsList
                                                                .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        medicationsList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );

    /*return SizedBox(
      height: 0,
    );*/
  }

  getNutritionTreatmentCard() {
    return FutureBuilder(
      future: nutritionFuture,
      builder: (context, AsyncSnapshot snapshot) {
        //patientUser = user.User.fromSnapshot(snapshot.data);
        if (snapshot.connectionState == ConnectionState.done) {
          if (nutritionList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 1),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Alimentación",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        nutritionList.length > 3
                                                            ? 3
                                                            : nutritionList
                                                                .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        nutritionList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );
    /*
    return SizedBox(
      height: 0,
    );*/
  }

  getOtherTreatmentCard() {
    return FutureBuilder(
      future: othersFuture,
      builder: (context, AsyncSnapshot snapshot) {
        //patientUser = user.User.fromSnapshot(snapshot.data);
        if (snapshot.connectionState == ConnectionState.done) {
          if (othersList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 3),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Otros",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        othersList.length > 3
                                                            ? 3
                                                            : othersList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        othersList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );
/*    return SizedBox(
      height: 0,
    );*/
  }

  getActivityTreatmentCard() {
    return FutureBuilder(
      future: activityFuture,
      builder: (context, AsyncSnapshot snapshot) {
        //patientUser = user.User.fromSnapshot(snapshot.data);
        if (snapshot.connectionState == ConnectionState.done) {
          if (activitiesList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 2),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Actividad Física",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: activitiesList
                                                                .length >
                                                            3
                                                        ? 3
                                                        : activitiesList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        activitiesList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );
    /*
    return SizedBox(
      height: 0,
    );*/
  }

  getEmptyStateCard(String message, bool showButton) {
    return Container(
      width: double.infinity,
      height: 470,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 200,
                ),
                Text(
                  showButton
                      ? message
                      : 'No cuentas con un \ntratamiento actual',
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff999999),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                showButton
                    ? SizedBox(
                        height: 27,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: const Color(0xff2F8F9D),
                          textColor: Colors.white,
                          onPressed: () {
                            goToAddTreatment(false);
                          },
                          child: const Text(
                            'Agregar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
                const SizedBox(
                  height: 10,
                ),
              ])),
    );
  }

  void goToAddTreatment(bool update) {
    Navigator.push(
      context,
      MaterialPageRoute(
        //TODO: Review this
        builder: (context) => AddTreatmentScreen(
            detailedUser!.userId!, update ? currentTreatment : null),
      ),
    );
  }

  void deleteCurrentTreatment() {
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
                      borderRadius:
                          BorderRadius.all(const Radius.circular(10))),
                  content: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      SvgPicture.asset(
                        'assets/images/warning_icon.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('¿Desea eliminar el tratamiento\n actual?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
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
                                deleteCurrentTreatmentById();
                              },
                              child: const Text(
                                'Si, Eliminar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(
                                      color: Color(0xff9D9CB5),
                                      width: 1,
                                      style: BorderStyle.solid)),
                              padding: const EdgeInsets.all(15),
                              color: Colors.white,
                              textColor: const Color(0xff9D9CB5),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            )
                          ])
                    ],
                  ))
            ])
          ],
        );
      },
    );
  }

  Future<Treatment> getCurrentTReatmentById(String currentTreatment) async {
    final db = FirebaseFirestore.instance;
    var future =
        await db.collection(TREATMENTS_KEY).doc(currentTreatment).get();
    return Treatment.fromSnapshot(future);
  }

  Future<void> deleteCurrentTreatmentById() async {
    Navigator.pop(context);
    final db = FirebaseFirestore.instance;
    await db
        .collection(TREATMENTS_KEY)
        .doc(detailedUser!.currentTreatment)
        .delete()
        //.onError((error, stackTrace) => )
        .whenComplete(() => {
              db
                  .collection(USERS_COLLECTION_KEY)
                  .doc(detailedUser!.userId)
                  .update({
                PATIENT_CURRENT_TREATMENT_KEY: EMPTY_STRING_VALUE
              }).whenComplete(() => showSuccessDeleteDialog())
            });
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Operación\nExitosa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Se eliminó correctamente el\ntratamiento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
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
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => isDoctorView
                ? PatientDetailScreen(detailedUser!.userId!)
                : HomeScreen()));
  }

  Future<List<String>> getMedicationPrescriptions(
      String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][MEDICATION_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  Future<List<String>> getActivityPrescriptions(
      String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][ACTIVITY_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  Future<List<String>> getNutritionPrescriptions(
      String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][NUTRITION_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  Future<List<String>> getOthersPrescriptions(String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(OTHERS_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][OTHERS_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  getGradientColors(double percentage, [bool? inverted]) {
    var redList = <Color>[
      Color(0xff9D2F2F),
      Color(0xffE72A2A),
      Color(0xff9D2F2F)
    ];
    var blueList = <Color>[
      Color(0xff2F8F9D),
      Color(0xff47B4AC),
      Color(0xff2F8F9D)
    ];
    if (percentage >= 80) {
      return inverted != null && inverted ? blueList : redList;
    }
    return inverted != null && inverted ? redList : blueList;
  }

  String getAdherenceMessage() {
    double percentage = 81.0;
    if (percentage >= 80) {
      return "Ten cuidado, tus niveles de abandono al tratamiento son altos";
    }
    return "¡Sigue así con tu tratamiento!";
  }

  getColoredTriangle(double percentage) {
    if (percentage < 80) {
      return Image.asset(
        'assets/images/arrow_up_red.png',
        fit: BoxFit.none,
      );
    }
    return Image.asset(
      'assets/images/arrow_up_blue.png',
      fit: BoxFit.none,
    );
  }
}
