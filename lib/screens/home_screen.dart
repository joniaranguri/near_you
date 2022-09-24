import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/screens/login_screen.dart';
import 'package:near_you/screens/my_profile_screen.dart';
import 'package:near_you/screens/routine_detail_screen.dart.dart';
import 'package:near_you/screens/routine_screen.dart';
import 'package:near_you/screens/survey_screen.dart';
import 'package:near_you/widgets/firebase_utils.dart';

import '../Constants.dart';
import '../common/static_common_functions.dart';
import '../model/pending_vinculation.dart';
import '../model/user.dart' as user;
import '../widgets/dialogs.dart';
import '../widgets/patient_detail.dart';
import '../widgets/treatments_list.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  static double screenWidth = 0;
  static double screenHeight = 0;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class MySliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _maxExtent = 240;
  final VoidCallback onActionTap;
  static double publicShrinkHome = 0;
  user.User? currentUser;

  Function initAllData;

  MySliverHeaderDelegate(
      {required this.onActionTap,
      required this.currentUser,
      required this.initAllData});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    HomeScreen.screenWidth = MediaQuery.of(context).size.width;
    HomeScreen.screenHeight = MediaQuery.of(context).size.height;
    publicShrinkHome = shrinkOffset;
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
          getImageUser(context, shrinkOffset, _maxExtent),
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
          Positioned(
            top: 0,
            right: 0,
            height: 80,
            child: IconButton(
                padding: const EdgeInsets.only(right: 25, top: 30, bottom: 25),
                constraints: const BoxConstraints(),
                icon: SvgPicture.asset(
                  'assets/images/refresh_icon.svg',
                ),
                onPressed: () {
                  initAllData();
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
    if (shrinkOffset > (maxExtent * 0.1)) {
      return SizedBox.shrink();
    } else {
      return FlatButton(
        height: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
        color: Colors.white,
        onPressed: () {
          currentUser!.isPatiente()
              ? (isNotEmtpy(currentUser!.medicoId)
                  ? showDialogDevinculation(context, currentUser!.userId!, true,
                      () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => HomeScreen()));
                    })
                  : showDialogVinculation(
                      currentUser!.fullName ?? "Nombre",
                      currentUser!.email!,
                      context,
                      currentUser!.isPatiente(),
                      () {}, () {
                      Navigator.pop(context);
                      dialogWaitVinculation(context, () {
                        Navigator.pop(context);
                      }, currentUser!.isPatiente());
                    }))
              : () {};
        },
        child: Text(
          currentUser!.isPatiente()
              ? (isNotEmtpy(currentUser!.medicoId) ? 'Desvincular' : 'Vincular')
              : 'Notificaciones',
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

  getImageUser(BuildContext context, double shrinkOffset, double maxExtent) {
    if (shrinkOffset > (maxExtent * 0.1)) {
      return const SizedBox.shrink();
    }
    return Align(
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
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            MyProfileScreen(currentUser)));
              },
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
            ))
        /*SvgPicture.asset(
              'assets/images/tab_plus_selected.svg',
              height: 70,
            )*/
        );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // bool isUserPatient = false;
  user.User? currentUser;
  Future<DocumentSnapshot>? futureUser;
  late ValueNotifier<bool> notifier = ValueNotifier(false);
  List<PendingVinculation> pendingVinculationList = <PendingVinculation>[];

  @override
  void initState() {
    initAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeScreen.screenWidth = MediaQuery.of(context).size.width;
    HomeScreen.screenHeight = MediaQuery.of(context).size.height;
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
                    currentUser: currentUser,
                    initAllData: () {
                      initAllData();
                    }),
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
                                  return Padding(
                                      padding: EdgeInsets.only(
                                          top: HomeScreen.screenHeight * 0.3),
                                      child: CircularProgressIndicator());
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
              goToAllRoutines();
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
              goToMyRoutine();
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
      child: Material(
        elevation: 0.0,
        color: Colors.white,
        child: BottomNavigationBar(
          elevation: 0,
          onTap: (index) {
            _currentIndex = index;
            if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          MyProfileScreen(currentUser)));
            }
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
      return Padding(
          padding: EdgeInsets.only(top: HomeScreen.screenHeight * 0.3),
          child: CircularProgressIndicator());
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
      showDialogVinculation(
          currentUser!.fullName ?? "Nombre",
          currentUser!.email!,
          context,
          currentUser!.isPatiente(),
          errorVinculation,
          successPendingVinculation);
    }
  }

/* void startVinculation(String? emailPatient) {
    attachMedicoToPatient(emailPatient);
  }

 Future<void> attachMedicoToPatient(String? emailPatient) async {
    final db = FirebaseFirestore.instance;
    String? medicoId = FirebaseAuth.instance.currentUser?.uid;
    if (medicoId == null) return;
    String? patientId = await getUserIdByEmail(emailPatient);
    if (patientId == null) {
      //error no id for email
      Navigator.pop(context);
    }
    var postDocRef = db.collection(USERS_COLLECTION_KEY).doc(patientId);
    await postDocRef
        .update({
          MEDICO_ID_KEY: medicoId,
          // ....rest of your data
        })
        .whenComplete(() => refreshScreen())
        .onError((error, stackTrace) => Navigator.pop(context));
  }*/

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

  errorVinculation() {
    print("error vinculation");
  }

  successPendingVinculation() {
    Navigator.pop(context);
    dialogWaitVinculation(context, () {
      Navigator.pop(context);
    }, currentUser!.isPatiente());
  }

  Future<List<PendingVinculation>> getPendingVinculations() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection(PENDING_VINCULATIONS_COLLECTION_KEY);
    final String currentUserId = currentUser!.userId!;
    QuerySnapshot<Map<String, dynamic>> future;
    if (currentUser!.isPatiente()) {
      future = await collectionRef
          .where(PATIENT_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_PENDING)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_MEDICO)
          .limit(1)
          .get();
    } else {
      future = await collectionRef
          .where(MEDICO_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_PENDING)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_PACIENTE)
          .get();
    }

    List<PendingVinculation> vinculations = <PendingVinculation>[];
    for (var element in future.docs) {
      PendingVinculation currentVinculation =
          PendingVinculation.fromSnapshot(element);
      vinculations.add(currentVinculation);
    }
    return vinculations;
  }

  Future<List<PendingVinculation>> getRefusedVinculations() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection(PENDING_VINCULATIONS_COLLECTION_KEY);
    final String currentUserId = currentUser!.userId!;
    QuerySnapshot<Map<String, dynamic>> future;
    if (currentUser!.isPatiente()) {
      future = await collectionRef
          .where(PATIENT_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_REFUSED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_PACIENTE)
          .limit(1)
          .get();
    } else {
      future = await collectionRef
          .where(MEDICO_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_REFUSED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_MEDICO)
          .get();
    }

    List<PendingVinculation> vinculations = <PendingVinculation>[];
    for (var element in future.docs) {
      PendingVinculation currentVinculation =
          PendingVinculation.fromSnapshot(element);
      vinculations.add(currentVinculation);
    }
    return vinculations;
  }

  Future<List<PendingVinculation>> getAcceptedVinculations() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection(PENDING_VINCULATIONS_COLLECTION_KEY);
    final String currentUserId = currentUser!.userId!;
    QuerySnapshot<Map<String, dynamic>> future;
    if (currentUser!.isPatiente()) {
      future = await collectionRef
          .where(PATIENT_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_ACCEPTED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_PACIENTE)
          .limit(1)
          .get();
    } else {
      future = await collectionRef
          .where(MEDICO_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_ACCEPTED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_MEDICO)
          .get();
    }

    List<PendingVinculation> vinculations = <PendingVinculation>[];
    for (var element in future.docs) {
      PendingVinculation currentVinculation =
          PendingVinculation.fromSnapshot(element);
      vinculations.add(currentVinculation);
    }
    return vinculations;
  }

  void showNotificationPendingVinculation(
      PendingVinculation pendingVinculation) {
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
                    Text("Notificación de\n Vinculación",
                        textAlign: TextAlign.center)
                  ]),
                  titleTextStyle: TextStyle(
                      fontSize: 20,
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
                      Text(
                          'El médico ${pendingVinculation.namePending}\n desea vincular su cuenta\n con usted',
                          textAlign: TextAlign.center,
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
                                acceptVinculationWithDoctor(
                                    pendingVinculation.medicoId,
                                    pendingVinculation.databaseId!);
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
                                noAcceptVinculation(
                                    pendingVinculation.databaseId!);
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

  Future<void> acceptVinculationWithDoctor(
      String? medicoId, String pendingVinculationId) async {
    final db = FirebaseFirestore.instance;
    String? patientId = FirebaseAuth.instance.currentUser?.uid;
    if (patientId == null || medicoId == null) {
      return;
    }
    updatePendingVinculationStatus(
        VINCULATION_STATUS_ACCEPTED, pendingVinculationId);
    var postDocRef = db.collection(USERS_COLLECTION_KEY).doc(patientId);
    await postDocRef.update({
      MEDICO_ID_KEY: medicoId,
      // ....rest of your data
    }).then((value) => showDialogSuccessVinculation(context,
            '¡Todo listo!\nSu ${currentUser!.isPatiente() ? "médico" : "paciente"} fue vinculado \ncorrectamente.',
            () {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen()));
        }));
  }

  void noAcceptVinculation(String pendingVinculationId) {
    Navigator.pop(context);
    updatePendingVinculationStatus(
        VINCULATION_STATUS_REFUSED, pendingVinculationId);
  }

  Future<void> updatePendingVinculationStatus(
      String status, String pendingVinculationId) async {
    final db = FirebaseFirestore.instance;
    await db
        .collection(PENDING_VINCULATIONS_COLLECTION_KEY)
        .doc(pendingVinculationId)
        .update({VINCULATION_STATUS_KEY: status});
  }

  void goToMyRoutine() {
    if (currentUser!.currentTreatment != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RoutineDetailScreen(currentUser!.currentTreatment!),
        ),
      );
    }
  }

  void goToAllRoutines() {
    if (currentUser!.currentTreatment != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutineScreen(currentUser!.currentTreatment!),
        ),
      );
    }
  }

  void initAllData() {
    futureUser = getUserById(FirebaseAuth.instance.currentUser!.uid);
    futureUser?.then((value) => {
          setState(() {
            currentUser = user.User.fromSnapshot(value);
            notifier = ValueNotifier(false);
            getPendingVinculations().then((pendingResult) => {
                  setState(() {
                    if (pendingResult.isEmpty) {
                      return;
                    }
                    pendingVinculationList = pendingResult;
                    if (currentUser!.isPatiente()) {
                      showNotificationPendingVinculation(
                          pendingVinculationList[0]);
                    }
                  })
                });

            getRefusedVinculations().then((refusedList) => {
                  setState(() {
                    for (int i = 0; i < refusedList.length; i++) {
                      deleteVinculation(refusedList[i].databaseId!);
                    }
                  })
                });

            getAcceptedVinculations().then((acceptedList) => {
                  setState(() {
                    if (acceptedList.isEmpty) {
                      return;
                    }
                    if (currentUser!.isPatiente()) {
                      dialogSuccessDoctorAccepts(context);
                      deleteVinculation(acceptedList.first.databaseId!);
                    }
                  })
                });
          })
        });
  }
}
