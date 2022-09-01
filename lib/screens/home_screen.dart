import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_you/screens/login_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart';
import '../widgets/grouped_bar_chart.dart';
import '../model/user.dart' as user;
import '../widgets/treatments_list.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class MySliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _maxExtent = 240;
  final VoidCallback onActionTap;
  static double publicShrinkHome = 0;
  user.User? currentUser;

  MySliverHeaderDelegate(
      {required this.onActionTap, required this.currentUser});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    publicShrinkHome = shrinkOffset;
    debugPrint(shrinkOffset.toString());
    return Container(
      color: Color(0xff2F8F9D),
      padding: EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          Align(
              alignment: Alignment(
                  //little padding
                  0,
                  100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: getPaddingTopTitle(shrinkOffset, maxExtent)),
                      child: Text(
                          currentUser != null
                              ? currentUser?.fullName ??
                                  currentUser?.type ??
                                  "Nombre"
                              : "Nombre",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                  //apply padding to all four sides
                  Text(
                    currentUser != null
                        ? currentUser?.illness ?? 'Diabetes Typo 2'
                        : 'Enfermedad',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  getButtonVinculation(context, shrinkOffset, _maxExtent)
                ],
              )),
          Align(
              alignment: Alignment(
                  //little padding
                  shrinkOffset / _maxExtent,
                  0),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30,
                    top: (shrinkOffset / _maxExtent) * 35,
                    right: 30,
                    bottom: 20),
                child: Container(
                    child: Image.asset(
                  'assets/images/person_default.png',
                  height: 50,
                )),
              )
              /*SvgPicture.asset(
              'assets/images/tab_plus_selected.svg',
              height: 70,
            )*/
              ),

          // here provide actions
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
                padding: const EdgeInsets.only(left: 25, top: 30, bottom: 25),
                constraints: const BoxConstraints(),
                icon: SvgPicture.asset(
                  'assets/images/log_out.svg',
                ),
                onPressed: () {
                  logOut(context);
                }),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => kToolbarHeight * 2;

  @override
  bool shouldRebuild(covariant MySliverHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }

  Future<void> logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
  }

  Widget getButtonVinculation(
    context,
    double shrinkOffset,
    double maxExtent,
  ) {
    if (shrinkOffset > (maxExtent * 0.2)) {
      return SizedBox.shrink();
    } else {
      return FlatButton(
        height: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
        color: Colors.white,
        onPressed: () {},
        child: Text(
          'Vincular',
          style: TextStyle(
              fontSize: getFontSizeVinculation(shrinkOffset, maxExtent),
              fontWeight: FontWeight.bold,
              color: Color(0xff9D9CB5)),
        ),
      );
    }
  }

  getPaddingTopTitle(double shrinkOffset, double maxExtent) {
    var result = maxExtent - (110 + shrinkOffset);
    if (result < 0) {
      result = 0;
    }
    return result;
  }

  getHeightVinculationButton(double shrinkOffset, double maxExtent) {
    var result = maxExtent / 12 - (shrinkOffset / 2);
    if (result < 0) {
      result = 0;
    }
    return result;
  }

  getFontSizeVinculation(double shrinkOffset, double maxExtent) {
    var result = maxExtent / 17 - (shrinkOffset / 2);
    if (result < 0) {
      result = 0;
    }
    return result;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // bool isUserPatient = false;
  user.User? currentUser;

  late final Future<DocumentSnapshot> futureUser;

  @override
  void initState() {
    futureUser = getCurrentUser();
    futureUser.then((value) => {
          setState(() {
            currentUser = user.User.fromSnapshot(value);
          })
        });
    super.initState();
    //initStateAsync();
  }

  @override
  Widget build(BuildContext context) {
    final expandedHeight = MediaQuery.of(context).size.height * 0.2;
    return Stack(children: <Widget>[
      Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverPersistentHeader(
                pinned: true,
                delegate: MySliverHeaderDelegate(
                    onActionTap: () {
                      debugPrint("on Tap");
                    },
                    currentUser: currentUser),
              ),
            ];
          },
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
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
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
                                height: getTopPaddingBody(),
                              ),
                              FutureBuilder(
                                future: futureUser,
                                builder: (context, AsyncSnapshot snapshot) {
                                  //currentUser = user.User.fromSnapshot(snapshot.data);
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
        ),
        bottomNavigationBar: _buildBottomBar(),
        floatingActionButton: Container(
          padding: EdgeInsets.only(top: 40),
          child: SvgPicture.asset(
            'assets/images/tab_plus_selected.svg',
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    ]);
  }

  var _currentIndex = 1;

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
            setState(() {});
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

  getTopPaddingBody() {
    if (MySliverHeaderDelegate.publicShrinkHome < 120) {
      return 7.toDouble();
    } else {
      var cant =
          (MySliverHeaderDelegate.publicShrinkHome - 168.toDouble()) / 10;
      return (50 + cant * 9.3).toDouble();
    }
  }

  getScreenType() {
    if (currentUser == null) {
      return CircularProgressIndicator();
    } else if (currentUser!.isPatiente()) {
      return patientScreen();
    } else {
      return medicoScreen();
    }
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

  medicoScreen() {
    return Column(
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[]),
        const SizedBox(
          height: 20,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const <Widget>[
              Text(
                'Mis pacientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff999999),
                ),
              )
            ]),
         SizedBox(
          height: 500,
        child: ListViewHomeLayout())
        //SizedBox
      ],
    );
  }

  Future<DocumentSnapshot> getCurrentUser() async {
    final db = FirebaseFirestore.instance;
    var userDocRef = db
        .collection(USERS_COLLECTION_KEY)
        .doc(FirebaseAuth.instance.currentUser?.uid);
    return await userDocRef.get();
  }
}
