import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/screens/add_prescription_screen.dart';
import 'package:near_you/screens/patient_detail_screen.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:intl/intl.dart';

import '../Constants.dart';
import '../common/static_common_functions.dart';
import '../model/user.dart' as user;
import '../widgets/firebase_utils.dart';

class AddTreatmentScreen extends StatefulWidget {
  String userId;
  Treatment? currentTreatment;

  AddTreatmentScreen(this.userId, [this.currentTreatment]);

  static const routeName = '/add_treatment';

  @override
  _AddTreatmentScreenState createState() =>
      _AddTreatmentScreenState(userId, currentTreatment);
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  static List<String> durationsList = ["días", "semanas", "meses", "años"];
  static List<String> statesList = ["Activo", "Inactivo"];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userId;
  user.User? patientUser;
  late final Future<DocumentSnapshot> futureUser;
  static StaticComponents staticComponents = StaticComponents();
  String? durationTypeValue;
  String? durationValue;
  String? stateValue;
  String? descriptionValue;
  String? startDateValue;
  String? endDateValue;
  bool startDateError = false;
  bool endDateError = false;
  bool durationError = false;
  bool durationTypeError = false;
  bool stateError = false;
  bool descriptionError = false;
  Treatment? currentTreatment;
  late final bool isUpdate;
  var _currentIndex = 1;

  bool showAddPrescriptionCards = false;

  bool hasPendingTreatment = false;

  String? pendingTreatmentId;
  String? medicationCardLabel;

  String? nutritionCardLabel;
  String? activityCardLabel;
  String? othersCardLabel;

  _AddTreatmentScreenState(this.userId, this.currentTreatment) {
    isUpdate = currentTreatment != null;
  }

  get borderWhite => OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(5));

  get borderGray => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(5));

  @override
  void initState() {
    futureUser = getUserById(userId);
    futureUser.then((value) => {
          setState(() {
            patientUser = user.User.fromSnapshot(value);
          })
        });
    super.initState();
    if (isUpdate && currentTreatment != null) {
      setState(() {
        durationTypeValue = currentTreatment!.durationType;
        durationValue = currentTreatment!.durationNumber;
        stateValue = currentTreatment!.state;
        descriptionValue = currentTreatment!.description;
        startDateValue = currentTreatment!.startDate;
        endDateValue = currentTreatment!.endDate;
      });
    }
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
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                      isUpdate ? 'Actualizar Tratamiento' : 'Tratamiento',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold))),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  discardChangesAndGoBack();
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
    return getCurrentTreatment();
  }

  getCurrentTreatment() {
    return SizedBox(
      width: 400,
      height: 580,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
                Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Completa las casillas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2F8F9D),
                      ),
                    )
                  ]),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                width: double.infinity,
                height: 520,
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 200,
                        ),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              left: 15,
                                              right: 15,
                                              bottom: 5),
                                          child: Text(
                                            "ID Tratamiento",
                                            style: TextStyle(
                                                color: Color(0xff999999),
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14),
                                          )),
                                      Container(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              left: 20,
                                              right: 20,
                                              bottom: 5),
                                          decoration: BoxDecoration(
                                              color: const Color(0xff2F8F9D),
                                              border: Border.all(
                                                  width: 1,
                                                  color:
                                                      const Color(0xff2F8F9D)),
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Fecha de inicio",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
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
                                          text: startDateValue),
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
                                          fillColor: Colors.white,
                                          enabledBorder: staticComponents
                                              .middleInputBorder,
                                          border: staticComponents
                                              .middleInputBorder,
                                          focusedBorder: staticComponents
                                              .middleInputBorder),
                                    )),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Fecha de fin",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                    height: endDateError ? 55 : 35,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value == '') {
                                          setState(() {
                                            endDateError = true;
                                          });
                                          return "Complete el campo";
                                        }
                                        setState(() {
                                          endDateError = false;
                                        });
                                      },
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: endDateValue),
                                      onTap: () {
                                        selectEndDate(context);
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
                                          fillColor: Colors.white,
                                          enabledBorder: staticComponents
                                              .middleInputBorder,
                                          border: staticComponents
                                              .middleInputBorder,
                                          focusedBorder: staticComponents
                                              .middleInputBorder),
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
                                const SizedBox(
                                  height: 10,
                                ),
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
                                              if (value == null ||
                                                  value == '') {
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
                                                text: durationValue),
                                            onChanged: (value) {
                                              durationValue = value;
                                            },
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: staticComponents
                                                .getMiddleInputDecoration('15'),
                                          )),
                                    ),
                                    Flexible(
                                        child: SizedBox(
                                            height: 35,
                                            child: Container(
                                              decoration: BoxDecoration(
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
                                                    child:
                                                        DropdownButton<String>(
                                                      hint: Text(
                                                        'Seleccionar',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF999999)),
                                                      ),
                                                      dropdownColor:
                                                          Colors.white,
                                                      value: durationTypeValue,
                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                    .only(
                                                                end: 12.0),
                                                        child: Icon(
                                                            Icons
                                                                .keyboard_arrow_down,
                                                            color: Color(
                                                                0xff999999)), // myIcon is a 48px-wide widget.
                                                      ),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          durationTypeValue =
                                                              newValue
                                                                  .toString();
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Estado",
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
                                          value: stateValue,
                                          icon: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(end: 12.0),
                                            child: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Color(
                                                    0xff999999)), // myIcon is a 48px-wide widget.
                                          ),
                                          onChanged: (newValue) {
                                            setState(() {
                                              stateValue = newValue.toString();
                                            });
                                          },
                                          items: statesList.map((String item) {
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
                                    Text("Descripción",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                    validator: (value) {
                                      if (value == null || value == '') {
                                        setState(() {
                                          descriptionError = true;
                                        });
                                        return "Complete el campo";
                                      }
                                      setState(() {
                                        descriptionError = false;
                                      });
                                    },
                                    minLines: 1,
                                    maxLines: 10,
                                    controller: TextEditingController(
                                        text: descriptionValue),
                                    onChanged: (value) {
                                      descriptionValue = value;
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      prefixIcon: Icon(Icons.circle,
                                          color: Color(0xff999999)),
                                      suffixIcon: IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.delete,
                                              color: Color(0xff999999))),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText:
                                          "Glucosa 110ml/g\nActividad física: 1hora",
                                      hintStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF999999)),
                                      focusedBorder: borderWhite,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    )
                                    // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                                    ),
                                const SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Feedback.forTap(context);
                                      setState(() {
                                        showAddPrescriptionCards =
                                            !showAddPrescriptionCards;
                                      });
                                    },
                                    child: TextField(
                                        minLines: 1,
                                        maxLines: 10,
                                        enabled: false,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF999999)),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          prefixIcon: Icon(Icons.circle,
                                              color: Colors.white),
                                          filled: true,
                                          fillColor: Color(0xffD9D9D9),
                                          hintText:
                                              "Agregar una nueva\n prescripción",
                                          hintStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF999999)),
                                          focusedBorder: borderGray,
                                          border: borderGray,
                                          enabledBorder: borderGray,
                                        )
                                        // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                                        )),
                                const SizedBox(
                                  height: 30,
                                ),
                                getAddPrescriptionCards(),
                                getTreatmentButtons()
                              ],
                            )))),
              ),
            ])

            //SizedBox
          ],
        ), //Column
      ), //Padding
    );
  }

  getMedicationTreatmentCard() {
    return InkWell(
      onTap: () {
        goToAddPrescription(0);
      },
      child: Card(
          color: Color(0xffF1F1F1),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3))),
            child: Container(
                height: 75,
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: Color(0xff2F8F9D), width: 5))),
                child: Column(
                  children: [
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 12, top: 5, right: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        padding:
                            const EdgeInsets.only(left: 25, top: 7, bottom: 7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        medicationCardLabel == null
                                            ? "Haga click para agregar una preescripción de glucosa"
                                            : medicationCardLabel!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                      )
                                    ]),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                      width: 24,
                                      height: 24,
                                      child: Icon(Icons.chevron_right,
                                          color: Color(0xff2F8F9D))))
                            ]))
                    //SizedBox
                  ],
                )),
          )),
    );
    return SizedBox(
      height: 0,
    );
  }

  getNutritionTreatmentCard() {
    return InkWell(
      onTap: () {
        goToAddPrescription(1);
      },
      child: Card(
          color: Color(0xffF1F1F1),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: ClipPath(
            child: Container(
                height: 75,
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: Color(0xff2F8F9D), width: 5))),
                child: Column(
                  children: [
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 12, top: 5, right: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        padding:
                            const EdgeInsets.only(left: 25, top: 7, bottom: 7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        nutritionCardLabel == null
                                            ? "Haga click para agregar una preescripción de alimentación"
                                            : nutritionCardLabel!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                      )
                                    ]),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(right: 5),
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
    return SizedBox(
      height: 0,
    );
  }

  getOtherTreatmentCard() {
    return InkWell(
      onTap: () {
        goToAddPrescription(3);
      },
      child: Card(
          color: Color(0xffF1F1F1),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: ClipPath(
            child: Container(
                height: 75,
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: Color(0xff2F8F9D), width: 5))),
                child: Column(
                  children: [
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 12, top: 5, right: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        padding:
                            const EdgeInsets.only(left: 25, top: 7, bottom: 7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        othersCardLabel == null
                                            ? "Haga click para agregar una preescripción de otro tipo"
                                            : othersCardLabel!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                      )
                                    ]),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(right: 5),
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
    return SizedBox(
      height: 0,
    );
  }

  getActivityTreatmentCard() {
    return InkWell(
      onTap: () {
        goToAddPrescription(2);
      },
      child: Card(
          color: Color(0xffF1F1F1),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: ClipPath(
            child: Container(
                height: 75,
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: Color(0xff2F8F9D), width: 5))),
                child: Column(
                  children: [
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 12, top: 5, right: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        padding:
                            const EdgeInsets.only(left: 25, top: 7, bottom: 7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        activityCardLabel == null
                                            ? "Haga click para agregar una preescripción de Actividad Física"
                                            : activityCardLabel!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                      )
                                    ]),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(right: 5),
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
    return SizedBox(
      height: 0,
    );
  }

  getTreatmentButtons() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(
            height: 17,
          ),
          FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: const Color(0xff2F8F9D),
            textColor: Colors.white,
            onPressed: validateAndSave,
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          FlatButton(
            shape: RoundedRectangleBorder(
                side: const BorderSide(
                    color: Color(0xff9D9CB5),
                    width: 1,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(30)),
            textColor: const Color(0xff9D9CB5),
            onPressed: () {
              discardChangesAndGoBack();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ]);
  }

  void startPatientVinculation() {}

  void addPrescription() {}

  void validateAndSave() {
    final FormState? form = _formKey.currentState;
    bool durationValid = isNotEmtpy(durationTypeValue);
    bool stateValid = isNotEmtpy(stateValue);
    bool isValidDropdowns = durationValid && stateValid;
    durationTypeError = !durationValid;
    stateError = !stateValid;
    if ((form?.validate() ?? false) && isValidDropdowns) {
      saveIdDatabase();
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(21001, 1, 1),
    );

    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (d != null && time != null) {
      setState(() {
        endDateValue = DateFormat('dd - MMM yyyy ').format(d) +
            '${time.hour}:${time.minute}';
      });
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(21001, 1, 1),
    );

    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (d != null && time != null) {
      setState(() {
        startDateValue = DateFormat('dd - MMM yyyy ').format(d) +
            '${time.hour}:${time.minute}';
      });
    }
  }

  void saveIdDatabase() {
    final db = FirebaseFirestore.instance;
    String? medicoId = FirebaseAuth.instance.currentUser?.uid;
    final newTreatment = <String, String>{
      USER_ID_KEY: userId,
      MEDICO_ID_KEY: medicoId!,
      TREATMENT_START_DATE_KEY: startDateValue!,
      TREATMENT_END_DATE_KEY: endDateValue!,
      TREATMENT_DURATION_NUMBER_KEY: durationValue!,
      TREATMENT_DURATION_TYPE_KEY: durationTypeValue!,
      TREATMENT_DESCRIPTION_KEY: descriptionValue!,
      TREATMENT_STATE_KEY: stateValue!
    };
    if (isUpdate || hasPendingTreatment) {
      final String? treatmentToUpdate =
          isUpdate ? patientUser?.currentTreatment : pendingTreatmentId;
      db
          .collection(TREATMENTS_KEY)
          .doc(treatmentToUpdate)
          .set(newTreatment)
          .then((value) => {
                if (isUpdate)
                  {goBackScreen()}
                else
                  {savePendingTreatmentAndGoBack(pendingTreatmentId!)}
              });
    } else {
      db
          .collection(TREATMENTS_KEY)
          .add(newTreatment)
          .then((treatment) => savePendingTreatmentAndGoBack(treatment.id));
    }
  }

  goBackScreen() {
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                PatientDetailScreen(patientUser!.userId!)));
  }

  void goToAddPrescription(int currentIndex) {
    String? medicoId = FirebaseAuth.instance.currentUser?.uid;
    if (!isUpdate && pendingTreatmentId == null) {
      final db = FirebaseFirestore.instance;
      db.collection(TREATMENTS_KEY).add({
        USER_ID_KEY: userId,
        MEDICO_ID_KEY: medicoId!,
      }).then((treatment) => savePendingTreatment(treatment, currentIndex));
    } else {
      var currentTreatmentId =
          patientUser?.currentTreatment ?? pendingTreatmentId;
      navigateWithResult(currentTreatmentId, currentIndex);
    }
  }

  void navigateWithResult(String? currentTreatmentId, int currentIndex) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    AddPrescriptionScreen(currentTreatmentId, currentIndex)))
        .then((value) => updateUIWithPrescriptions(value));
  }

  getAddPrescriptionCards() {
    if (showAddPrescriptionCards) {
      return Column(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Prescripción",
                  style: TextStyle(
                      color: Color(0xff2F8F9D),
                      fontWeight: FontWeight.normal,
                      fontSize: 14),
                )
              ]),
          const SizedBox(
            height: 10,
          ),
          getMedicationTreatmentCard(),
          getNutritionTreatmentCard(),
          getActivityTreatmentCard(),
          getOtherTreatmentCard(),
        ],
      );
    } else {
      return staticComponents.emptyBox;
    }
  }

  savePendingTreatment(
      DocumentReference<Map<String, dynamic>> treatment, int currentIndex) {
    hasPendingTreatment = true;
    pendingTreatmentId = treatment.id;
    navigateWithResult(pendingTreatmentId, currentIndex);
  }

  updateUIWithPrescriptions(value) {
    if (value == null) {
      if (!isUpdate) {
        hasPendingTreatment = false;
        pendingTreatmentId = null;
      }
      return;
    }

    switch (int.parse(value.toString())) {
      case 0:
        medicationCardLabel = 'Toca aquí para editar \nmedicación';
        break;
      case 1:
        nutritionCardLabel = 'Toca aquí para editar \nalimentación';
        break;
      case 2:
        activityCardLabel = 'Toca aquí para editar \nla actividad física';

        break;
      case 3:
        othersCardLabel = 'Toca aquí para editar otras \nvariables';
        break;
    }
    setState(() {});
  }

  void discardChangesAndGoBack() {
    if (hasPendingTreatment) {
      deletePendingPrescriptions(
          PENDING_MEDICATION_PRESCRIPTIONS_COLLECTION_KEY);
      deletePendingPrescriptions(PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY);
      deletePendingPrescriptions(
          PENDING_NUTRITION_PRESCRIPTIONS_COLLECTION_KEY);
      deletePendingPrescriptions(PENDING_Others_PRESCRIPTIONS_COLLECTION_KEY);
      final db = FirebaseFirestore.instance;
      db
          .collection(TREATMENTS_KEY)
          .doc(pendingTreatmentId)
          .delete()
          .whenComplete(() => Navigator.pop(context));
    } else {
      Navigator.pop(context);
    }
  }

  void deletePendingPrescriptions(String collectionId) {
    final db = FirebaseFirestore.instance;
    db
        .collection(collectionId)
        .where(PENDING_PRESCRIPTIONS_TREATMENT_KEY,
            isEqualTo: pendingTreatmentId)
        .get()
        .then((value) => {
              for (int i = 0; i < value.docs.length; i++)
                {value.docs[i].reference.delete()}
            });
  }

  savePendingTreatmentAndGoBack(String treatId) {
    final db = FirebaseFirestore.instance;
    try {
      deletePendingPrescriptions(
          PENDING_MEDICATION_PRESCRIPTIONS_COLLECTION_KEY);
      deletePendingPrescriptions(PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY);
      deletePendingPrescriptions(
          PENDING_NUTRITION_PRESCRIPTIONS_COLLECTION_KEY);
      deletePendingPrescriptions(PENDING_Others_PRESCRIPTIONS_COLLECTION_KEY);
    } catch (ex) {}
    db.collection(USERS_COLLECTION_KEY).doc(patientUser?.userId).update({
      PATIENT_CURRENT_TREATMENT_KEY: treatId,
    }).then((value) => goBackScreen());
  }
}
