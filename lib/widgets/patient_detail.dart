import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/screens/add_treatment_screen.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:near_you/widgets/treatments_list.dart';
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
  String? durationTypeValue;
  String? durationValue;
  String? stateValue;
  String? descriptionValue;
  String? startDateValue;
  String? endDateValue;

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
                          goBack();
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
                    blueIndicator,
                    grayIndicator,
                    grayIndicator
                  ]),
              //SizedBox
            ],
          ), //Column
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
                    SizedBox(height: 470, child: ListViewHomeLayout())
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
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                "Prescripciones",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ))
                        ]),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Prescripción 3/4",
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
    return InkWell(
      onTap: () {
        /* Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailScreen(treatments[index].userId),
        )
      );*/
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
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
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

  getNutritionTreatmentCard() {
    return InkWell(
      onTap: () {
        /* Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailScreen(treatments[index].userId),
        )
      );*/
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
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
        /* Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailScreen(treatments[index].userId),
        )
      );*/
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
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
        /* Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailScreen(treatments[index].userId),
        )
      );*/
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
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "• To be completed, to be completed, to be completed",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xff67757F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                                Navigator.pop(context);
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
}
