import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/widgets/patient_detail.dart';

import '../model/user.dart' as user;
import '../widgets/firebase_utils.dart';
import '../widgets/prescription_detail.dart';

class AddPrescriptionScreen extends StatefulWidget {
  static const routeName = '/add_prescription';

  var currentIndex;

  var treatmentId;

  AddPrescriptionScreen(this.treatmentId, this.currentIndex);

  @override
  _AddPrescriptionScreenState createState() =>
      _AddPrescriptionScreenState(treatmentId, currentIndex);
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  Treatment? currentTreatment;
  late final Future<DocumentSnapshot> futureTreatment;

  bool isModify = false;
  int _currentIndex = 1;

  String treatmentId;

  int currentPageIndex = 0;

  _AddPrescriptionScreenState(this.treatmentId, this.currentPageIndex);

  @override
  void initState() {
    futureTreatment = getTreatmentById(treatmentId);
    futureTreatment.then((value) => {
          setState(() {
            currentTreatment = Treatment.fromSnapshot(value);
            currentTreatment?.databaseId = treatmentId;
          })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Stack(children: <Widget>[
      Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80), // here the desired height
            child: AppBar(
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                      isModify ? "Actualizar \nPrescripción" : "Prescripción",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isModify ? 22 : 25,
                          fontWeight: FontWeight.bold))),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, widget.currentIndex);
                  //Navigator.pop(context);
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
                              future: futureTreatment,
                              builder: (context, AsyncSnapshot snapshot) {
                                //patientUser = user.User.fromSnapshot(snapshot.data);
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return getScreenType();
                                }
                                return const CircularProgressIndicator();
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
       /*  bottomNavigationBar: _buildBottomBar(),
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
                    startPatientVinculation();
                  });
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, */
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
    if (currentTreatment == null) {
      return CircularProgressIndicator();
    }
    return PrescriptionDetail.forDoctorView(currentTreatment, currentPageIndex);
  }

  void startPatientVinculation() {}
}
