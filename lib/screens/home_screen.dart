import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/screens/login_screen.dart';
import 'package:near_you/screens/survey_screen.dart';
import 'package:near_you/widgets/firebase_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:near_you/widgets/static_components.dart';

import '../Constants.dart';
import '../model/user.dart' as user;
import '../widgets/grouped_bar_chart.dart';
import '../widgets/patient_detail.dart';
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
                    getTextSubtitleHeader(),
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
                    decoration: BoxDecoration(
                      color: const Color(0xff7c94b6),
                      image: DecorationImage(
                        image: NetworkImage('http://i.imgur.com/QSev0hg.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      border: Border.all(
                        color: Color(0xff47B4AC),
                        width: 4.0,
                      ),
                    ),
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
                  showLogoutModal(context);
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
          currentUser!.isPatiente() ? 'Vincular' : 'Notificaciones',
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

  String getTextSubtitleHeader() {
    if (currentUser == null) {
      return "";
    }

    if (currentUser!.isPatiente()) {
      return currentUser?.illness ?? 'Diabetes Typo 2';
    }

    return currentUser?.illness ?? '4 pacientes';
  }

  void showLogoutModal(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  title: Column(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text("Cerrar sesión")
                  ]),
                  titleTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff67757F)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('¿Estás seguro que deseas ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff999999))),
                      const Text('cerrar la sesión?',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff999999))),
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
                                logOut(context);
                              },
                              child: const Text(
                                'Aceptar',
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
}

class _HomeScreenState extends State<HomeScreen> {
  // bool isUserPatient = false;
  user.User? currentUser;
  static StaticComponents staticComponents = StaticComponents();
  late final Future<DocumentSnapshot> futureUser;
  late ValueNotifier<bool> notifier = ValueNotifier(false);

  @override
  void initState() {
    futureUser = getUserById(FirebaseAuth.instance.currentUser!.uid);
    futureUser.then((value) => {
          setState(() {
            currentUser = user.User.fromSnapshot(value);
            notifier = ValueNotifier(false);
          })
        });
    super.initState();
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
                              Row(
                                children: [_getFABDial()],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                              )
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
        floatingActionButton: /* _getEmptyFABDial() */
            GestureDetector(
          child: Container(
            padding: EdgeInsets.only(top: 40),
            child: SvgPicture.asset(
              notifier.value
                  ? 'assets/images/tab_close_selected.svg'
                  : 'assets/images/tab_plus_selected.svg',
            ),
          ),
          onTap: () {
            executeMainAction();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    ]);
  }

  bool showMenu = false;

  Widget _getFABDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Colors.transparent,
      visible: false,
      curve: Curves.bounceIn,
      openCloseDial: notifier,
      onClose: () {
        setState(() {
          notifier.value = false;
        });
      },
      //spaceBetweenChildren: 100,
      spacing: 200,
      children: [
        SpeedDialChild(
            child: Icon(Icons.list, color: Colors.white),
            backgroundColor: Color(0xFF2F8F9D),
            onTap: () {
              /* do anything */
            },
            labelWidget: Text(
              "Todas mis Rutinas",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF47B4AC),
                  fontSize: 16.0),
            )),
        SpeedDialChild(
            child: Icon(Icons.playlist_add_check_outlined, color: Colors.white),
            backgroundColor: Color(0xFF2F8F9D),
            onTap: () {
              goToSurvey();
            },
            labelWidget: Text(
              "Encuestas",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF47B4AC),
                  fontSize: 16.0),
            )),
        SpeedDialChild(
            child: Icon(Icons.water_drop, color: Colors.white),
            backgroundColor: Color(0xFF2F8F9D),
            onTap: () {
              /* do anything */
            },
            labelWidget: Text(
              "Mi rutina",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF47B4AC),
                  fontSize: 16.0),
            ))
      ],
    );
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
      return PatientDetail.forPatientView(currentUser);
    } else {
      return medicoScreen();
    }
  }

  medicoScreen() {
    return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
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
            SizedBox(height: 500, child: ListViewHomeLayout())
            //SizedBox
          ],
        ));
  }

  void executeMainAction() {
    if (currentUser!.isPatiente()) {
      setState(() {
        //howMenu = false;
        notifier.value = true;
      });
    } else {
      showDialogVinculation();
    }
  }

  void showDialogVinculation() {
    String? emailPatient;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  title: Column(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text("Ingrese el correo electrónico")
                  ]),
                  titleTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff67757F)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: TextEditingController(text: emailPatient),
                        onChanged: (value) {
                          emailPatient = value;
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: staticComponents
                            .getInputDecoration('Correo del paciente'),
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
                                startVinculation(emailPatient);
                              },
                              child: const Text(
                                'Vincular',
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

  void startVinculation(String? emailPatient) {
    attachMedicoToPatient(emailPatient);
  }

  Future<void> attachMedicoToPatient(String? emailPatient) async {
    final db = FirebaseFirestore.instance;
    String? medicoId = FirebaseAuth.instance.currentUser?.uid;
    if (medicoId == null) return;
    var future = await db
        .collection(USERS_COLLECTION_KEY)
        .where(EMAIL_KEY, isEqualTo: emailPatient)
        .limit(1)
        .get();
    if (future.docs.isEmpty) {
      Navigator.pop(context);
      return;
    }
    String patientId = future.docs.first.id;
    var postDocRef = db.collection(USERS_COLLECTION_KEY).doc(patientId);
    await postDocRef
        .update({
          MEDICO_ID_KEY: medicoId,
          // ....rest of your data
        })
        .whenComplete(() => refreshScreen())
        .onError((error, stackTrace) => Navigator.pop(context));
  }

  refreshScreen() {
    Navigator.pop(context);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  void goToSurvey() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyScreen(
            currentUser!.userId!, currentUser!.fullName ?? "Paciente"),
      ),
    );
  }
}
