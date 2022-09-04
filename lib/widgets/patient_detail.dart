import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../model/user.dart' as user;
import '../widgets/grouped_bar_chart.dart';
import 'firebase_utils.dart';

class PatientDetailScreen extends StatefulWidget {
  String userId;

  PatientDetailScreen(this.userId);

  static const routeName = '/patient_detail';

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState(userId);
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  String userId;
  user.User? patientUser;
  late final Future<DocumentSnapshot> futureUser;

  _PatientDetailScreenState(this.userId);

  var _currentIndex = 1;

  @override
  void initState() {
    futureUser = getUserById(userId);
    futureUser.then((value) => {
          setState(() {
            patientUser = user.User.fromSnapshot(value);
          })
        });
    super.initState();
    //initStateAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80), // here the desired height
            child: AppBar(
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                      patientUser != null
                          ? patientUser?.fullName ??
                              patientUser?.type ??
                              "Nombre"
                          : "Nombre",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            FutureBuilder(
                              future: futureUser,
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
        floatingActionButton: /* _getEmptyFABDial() */
            GestureDetector(
          child: Container(
            padding: EdgeInsets.only(top: 40),
            child: SvgPicture.asset('assets/images/tab_plus_selected.svg'),
          ),
          onTap: () {
            setState(() {
              startPatientVinculation();
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    ]);
  }

  Widget _buildBottomBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
    if (patientUser == null) {
      return CircularProgressIndicator();
    }
    return patientScreen();
  }

  patientScreen() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      child: SizedBox(
        width: 400,
        height: 580,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
                  Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xff2F8F9D)),
                        onPressed: () {
                          setState(() {});
                        },
                      ),
                      Padding(
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
                        icon:
                            Icon(Icons.arrow_forward, color: Color(0xff2F8F9D)),
                        onPressed: () {
                          setState(() {});
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
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'ADHERENCIA',
                          style:
                              TextStyle(fontSize: 11, color: Color(0xff666666)),
                        ),
                        Text('NORMAL',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xff666666)))
                      ],
                    ),
                    linearGradient: LinearGradient(
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
              Container(height: 76, child: GroupedBarChart.withSampleData()),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
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
                  children: <Widget>[
                    Expanded(
                        child: SizedBox(
                      height: 6,
                      child: Center(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: Color(0xff2F8F9D),
                              borderRadius: BorderRadius.circular(5),
                              shape: BoxShape.rectangle),
                        ),
                      ),
                    )),
                    Expanded(
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
                    )),
                    Expanded(
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
                    ))
                  ]),

              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  void startPatientVinculation() {}
}
