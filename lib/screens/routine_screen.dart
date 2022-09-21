import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/common/survey_static_values.dart';
import 'package:near_you/model/routine.dart';
import 'package:near_you/screens/routine_detail_screen.dart.dart';

class RoutineScreen extends StatefulWidget {
  String? currentTreatmentId;

  RoutineScreen(this.currentTreatmentId);

  static const routeName = '/Routine';

  @override
  _RoutineScreenState createState() => _RoutineScreenState(currentTreatmentId);
}

class _RoutineScreenState extends State<RoutineScreen> {
  static List<SurveyData> RoutineList = <SurveyData>[];
   List<String?> RoutineResults = List.filled(RoutineList.length, '0');
  static List<Routine> routines = <Routine>[
    new Routine(
        treatmentId: null,
        medicationPercentage: "80",
        activityPercentage: "80",
        nutritionPercentage: "80",
        examsPercentage: "80",
    totalPercentage: "0")
  ];

  late final Future<List<SurveyData>> futureRoutine;
  var _currentIndex = 1;

  double percentageProgress = 0;

  double screenWidth = 0;

  double screenHeight = 0;

  String? currentTreatmentId;

  _RoutineScreenState(this.currentTreatmentId);

  @override
  void initState() {
    futureRoutine = getRoutineList();
    futureRoutine.then((value) => {
          setState(() {
            RoutineList = value;
            RoutineResults = List.filled(RoutineList.length, null);
          })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Stack(children: <Widget>[
      Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80), // here the desired height
            child: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    //
                  },
                )
              ],
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Rutinas',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold))),
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
                            /*  CalendarTimeline(
                              showYears: false,
                              initialDate: _selectedDate,
                              firstDate:
                                  _selectedDate.subtract(Duration(days: 30)),
                              lastDate: _selectedDate,
                              onDateSelected: (date) => {},
                              monthColor: Colors.white70,
                              dayColor: Colors.teal[200],
                              dayNameColor: Color(0xFF333A47),
                              activeDayColor: Colors.white,
                              activeBackgroundDayColor: Color(0xff2F8F9D),
                              dotsColor: Color(0xff2F8F9D),
                              selectableDayPredicate: (date) =>
                                  date == _selectedDate,
                              locale: 'es',
                            ),*/
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Horario',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff2F8F9D)),
                                ),
                              ],
                            ),
                            FutureBuilder(
                              future: futureRoutine,
                              builder: (context, AsyncSnapshot snapshot) {
                                //patientUser = user.User.fromSnapshot(snapshot.data);
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return getScreenType();
                                }
                                return CircularProgressIndicator();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ))
        ]),
        bottomNavigationBar: _buildBottomBar(),
        //TODO : REVIEW THIS
        floatingActionButton: keyboardIsOpened
            ? null
            : GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(top: 40),
                  child:
                      SvgPicture.asset('assets/images/tab_plus_selected.svg'),
                ),
                onTap: () {
                  setState(() {
                    //mostrar menu
                  });
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    ]);
  }

  Widget _buildBottomBar() {
    return Container(
      child: Material(
        elevation: 0.0,
        color: Colors.white,
        child: BottomNavigationBar(
          elevation: 0,
          onTap: (index) {
            _currentIndex = index;
          },
          backgroundColor: Colors.transparent,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/tab_metrics_unselected.svg',
                ),
                label: ""),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/tab_person_unselected.svg',
                ),
                label: "")
          ],
        ),
      ),
    );
  }

  getScreenType() {
    if (routines.isEmpty) {
      return noRoutineView();
    }
    return SizedBox(
      width: 400,
      height: 600,
      child: ListView.builder(
          itemCount: routines.length,
          padding: EdgeInsets.only(bottom: 60),
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("8:00"),
                ),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    if (isNotEmpty(currentTreatmentId)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RoutineDetailScreen(currentTreatmentId!),
                        ),
                      );
                    }
                  },
                  child: Card(
                      margin: EdgeInsets.all(20),
                      child: ClipPath(
                        child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Color(0xffF1F1F1),
                                border: Border(
                                    left: BorderSide(
                                        color: Color(0xff2F8F9D), width: 5))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: <Widget>[
                                  Text(
                                    "Completada",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2F8F9D),
                                    ),
                                  )
                                ]),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 20, top: 10, left: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Medicación: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        (routines[index].activityPercentage ??
                                                                    0)
                                                                .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              getAdherenceLevelColor(
                                                                  index),
                                                        ),
                                                      )
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Alimentación: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        (routines[index].activityPercentage ??
                                                                    0)
                                                                .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              getAdherenceLevelColor(
                                                                  index),
                                                        ),
                                                      )
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Actividad Física: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        (routines[index].activityPercentage ??
                                                                    0)
                                                                .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              getAdherenceLevelColor(
                                                                  index),
                                                        ),
                                                      )
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Exámenes: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        (routines[index].activityPercentage ??
                                                                    0)
                                                                .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              getAdherenceLevelColor(
                                                                  index),
                                                        ),
                                                      )
                                                    ]),
                                              ])
                                        ]))
                                //SizedBox
                              ],
                            )),
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3))),
                      )),
                ))
              ],
            );
          }), //Padding
    );
  }

  /*Future<List<RoutineData>> getRoutineQuestions() async {
    return StaticRoutine.RoutineStaticList;
  }
*/
  noRoutineView() {
    return Container(
      width: double.infinity,
      height: screenHeight,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'No registra aún ninguna\nrutina',
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff999999),
                    fontFamily: 'Italic',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                const SizedBox(
                  height: 10,
                ),
              ])),
    );
  }

  void saveAndGoBack() {
    /*  final db = FirebaseFirestore.instance;
    final data = <String, String>{};
    for (int i = 0; i < RoutineResults.length; i++) {
      data.putIfAbsent((i + 1).toString(), () => RoutineResults[i]!);
    }
    db
        .collection(USERS_COLLECTION_KEY)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(ROUTINES_COLLECTION_KEY)
        .add(data)
        .then((value) => dialogSuccess());*/
  }

  Future<List<SurveyData>> getRoutineList() async {
    return <SurveyData>[];
  }

  getAdherenceLevelColor(int index) {
    var value = 0xff47B4AC;
    int adherenceLevel =
        23; // int.parse(patients[index].adherenceLevel ?? "0");
    if (adherenceLevel <= 33) {
      value = 0xffF8191E;
    } else if (adherenceLevel <= 66) {
      value = 0xffFFCC4D;
    }
    return Color(value);
  }

  bool isNotEmpty(String? str) {
    return str != null && str != '';
  }
}
