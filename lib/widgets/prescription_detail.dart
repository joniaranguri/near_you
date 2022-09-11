import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/screens/add_treatment_screen.dart';
import 'package:near_you/screens/home_screen.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:near_you/widgets/treatments_list.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../common/static_common_functions.dart';
import '../model/user.dart' as user;
import '../widgets/grouped_bar_chart.dart';

class PrescriptionDetail extends StatefulWidget {
  final bool isDoctorView;
  Treatment? currentTreatment;

  PrescriptionDetail(this.currentTreatment, {required this.isDoctorView});

  factory PrescriptionDetail.forDoctorView(Treatment? paramTreatment) {
    return PrescriptionDetail(
      paramTreatment,
      isDoctorView: true,
    );
  }

  factory PrescriptionDetail.forPrescriptionView(Treatment? paramTreatment) {
    return PrescriptionDetail(
      paramTreatment,
      isDoctorView: false,
    );
  }

  @override
  PrescriptionDetailState createState() =>
      PrescriptionDetailState(this.currentTreatment, this.isDoctorView);
}

class PrescriptionDetailState extends State<PrescriptionDetail> {
  static StaticComponents staticComponents = StaticComponents();
  user.User? detailedUser;
  Treatment? currentTreatment;
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  bool isDoctorView = true;
  late final Future<Treatment> currentTreatmentFuture;
  String? durationTypeValue;
  String? durationValue;
  String? pastilleValue;
  String? pastilleQuantityValue;
  String? periodicityValue;
  String? descriptionValue;
  String? startDateValue;
  String? endDateValue;

  String? durationTypeActivityValue;

  int medicationsCount = 0;

  final GlobalKey<FormState> medicationFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> alimentationFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> phisicalActivityFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> othersFormState = GlobalKey<FormState>();

  bool startDateError = false;
  bool endDateError = false;
  bool durationError = false;
  bool durationTypeError = false;
  bool stateError = false;
  bool descriptionError = false;

  static List<String> durationsList = ["días", "semanas", "meses", "años"];
  static List<String> otherNamesList = [
    "Insulina",
    "Nivel de HbA1c",
    "LDL",
    "HDL",
    "Triglicérido",
    "Colesterol",
    "Riesgo cardiovascular"
  ];
  static List<String> durationsActivityList = ["horas", "segundos", "horas"];
  static List<String> pastilleTypeList = [
    "Pastilla antidiabética",
    "Otro tipo"
  ];
  static List<String> pastilleQuantitiesList = [
    "1 pastilla",
    "2 pastillas",
    "3 pastillas",
    "4 pastillas",
    "5 pastillas"
  ];
  static List<String> periodicityList = ["Diaria", "Semanal", "Mensual"];

  PrescriptionDetailState(this.currentTreatment, this.isDoctorView);

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

  get borderGray => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(5));

  get borderWhite => OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(5));

  get sizedBox10 => const SizedBox(height: 10);

  @override
  void initState() {
    currentTreatmentFuture =
        getCurrentTReatmentById(detailedUser!.currentTreatment!);
    currentTreatmentFuture.then((value) => {
          setState(() {
            currentTreatment = value;
            durationTypeValue = currentTreatment!.durationType;
            durationValue = currentTreatment!.durationNumber;
            pastilleValue = currentTreatment!.state;
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
          itemCount: 4,
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
    String title = "";
    Widget childView;
    switch (i) {
      case 0:
        title = "Medicación";
        childView = getMedicationView();
        break;
      case 1:
        title = "Alimentación";
        childView = getAlimentationView();
        break;
      case 2:
        title = "Actividad Física";
        childView = getPhisicalActivityView();
        break;
      default:
        title = "Otros";
        childView = getOthersView();
    }
    return getPrescriptionPage(i, title, childView);
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

  getPrescriptionPage(int index, String title, Widget childView) {
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
                            icon: Icon(index == 0 ? null : Icons.chevron_left,
                                size: 30, color: Color(0xff2F8F9D)),
                            onPressed: () {
                              if (index > 0) {
                                goBack();
                              }
                            },
                          ),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2F8F9D),
                            ),
                          ),
                          IconButton(
                            icon: Icon(index == 3 ? null : Icons.chevron_right,
                                size: 30, color: Color(0xff2F8F9D)),
                            onPressed: () {
                              if (index < 3) {
                                goAhead();
                              }
                            },
                          )
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    childView
                  ]),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    index == 0 ? blueIndicator : grayIndicator,
                    index == 1 ? blueIndicator : grayIndicator,
                    index == 2 ? blueIndicator : grayIndicator,
                    index == 3 ? blueIndicator : grayIndicator,
                  ]),
              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getMedicationButtons() {
    return isDoctorView
        ? Container(
            height: 190,
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
                          onPressed: validateAndSave,
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              'Cancelar',
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

  getAlimentationButtons() {
    return isDoctorView
        ? Container(
            height: 190,
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
                          onPressed: validateAndSave,
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              'Cancelar',
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

  getActivityButtons() {
    return isDoctorView
        ? Container(
            height: 190,
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
                          onPressed: validateAndSave,
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              'Cancelar',
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

  getMedicationView() {
    return Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 40),
                            onPressed: () {},
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 30,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          width: 150,
                          child: Text("Glucosa - 110ml/g",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xff999999)))),
                      SizedBox(
                          height: 35,
                          width: 14,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 14),
                            onPressed: () {},
                            icon: const Icon(Icons.edit,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 30),
                            onPressed: () {},
                            icon: const Icon(Icons.delete,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          ))
                    ],
                  ),
                  sizedBox10,
                  getFormOrButtonAddMedication()
                ],
              ))),
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
    /*  Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => isDoctorView
                ? PrescriptionDetailScreen(detailedUser!.userId!)
                : HomeScreen()));*/
  }

  void validateAndSave() {
    final FormState? form = medicationFormState.currentState;
    bool durationValid = isNotEmtpy(durationTypeValue);
    bool stateValid = isNotEmtpy(pastilleValue);
    bool isValidDropdowns = durationValid && stateValid;
    durationTypeError = !durationValid;
    stateError = !stateValid;
    if ((form?.validate() ?? false) && isValidDropdowns) {
      //saveIdDatabase();
    }
  }

  getFormOrButtonAddMedication() {
    return Container(
      width: double.infinity,
      height: 520,
      child: SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
              ),
              child: Form(
                  key: medicationFormState,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Fecha de inicio",
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xff999999)))
                              ],
                            ),
                            sizedBox10,
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
                                    //  selectStartDate(context);
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
                                      enabledBorder:
                                          staticComponents.middleInputBorder,
                                      border:
                                          staticComponents.middleInputBorder,
                                      focusedBorder:
                                          staticComponents.middleInputBorder),
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
                            sizedBox10,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Flexible(
                                  child: SizedBox(
                                      height: durationError ? 55 : 35,
                                      width: 111,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value == '') {
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
                                        style: const TextStyle(fontSize: 14),
                                        decoration: staticComponents
                                            .getMiddleInputDecoration('15'),
                                      )),
                                ),
                                Flexible(
                                    child: SizedBox(
                                        height: 35,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
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
                                            child: DropdownButtonHideUnderline(
                                              child: ButtonTheme(
                                                alignedDropdown: true,
                                                child: DropdownButton<String>(
                                                  hint: Text(
                                                    'Seleccionar',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF999999)),
                                                  ),
                                                  dropdownColor: Colors.white,
                                                  value: durationTypeValue,
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .only(end: 12.0),
                                                    child: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        color: Color(
                                                            0xff999999)), // myIcon is a 48px-wide widget.
                                                  ),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      durationTypeValue =
                                                          newValue.toString();
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
                            sizedBox10,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tipo",
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xff999999)))
                              ],
                            ),
                            sizedBox10,
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: stateError
                                        ? Colors.red
                                        : Color(0xFF999999),
                                    width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(
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
                                      value: pastilleValue,
                                      icon: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                end: 12.0),
                                        child: Icon(Icons.keyboard_arrow_down,
                                            color: Color(
                                                0xff999999)), // myIcon is a 48px-wide widget.
                                      ),
                                      onChanged: (newValue) {
                                        setState(() {
                                          pastilleValue = newValue.toString();
                                        });
                                      },
                                      items:
                                          pastilleTypeList.map((String item) {
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
                                Text("Dosis",
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xff999999)))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                                height: durationError ? 55 : 35,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value == '') {
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
                                  style: const TextStyle(fontSize: 14),
                                  decoration:
                                      staticComponents.getMiddleInputDecoration(
                                          'Después del almuerzo'),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Cantidad",
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xff999999)))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: stateError
                                        ? Colors.red
                                        : Color(0xFF999999),
                                    width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(
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
                                      value: pastilleQuantityValue,
                                      icon: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                end: 12.0),
                                        child: Icon(Icons.keyboard_arrow_down,
                                            color: Color(
                                                0xff999999)), // myIcon is a 48px-wide widget.
                                      ),
                                      onChanged: (newValue) {
                                        setState(() {
                                          pastilleQuantityValue =
                                              newValue.toString();
                                        });
                                      },
                                      items: pastilleQuantitiesList
                                          .map((String item) {
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
                            sizedBox10,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Periodicidad",
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xff999999)))
                              ],
                            ),
                            sizedBox10,
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: stateError
                                        ? Colors.red
                                        : Color(0xFF999999),
                                    width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(
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
                                      value: periodicityValue,
                                      icon: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                end: 12.0),
                                        child: Icon(Icons.keyboard_arrow_down,
                                            color: Color(
                                                0xff999999)), // myIcon is a 48px-wide widget.
                                      ),
                                      onChanged: (newValue) {
                                        setState(() {
                                          periodicityValue =
                                              newValue.toString();
                                        });
                                      },
                                      items: periodicityList.map((String item) {
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
                            sizedBox10,
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
                              validator: (value) {
                                if (value == null || value == '') {
                                  setState(() {
                                    durationError = true;
                                  });
                                  return "Complete el campo";
                                }
                                setState(() {
                                  durationError = false;
                                });
                              },
                              controller:
                                  TextEditingController(text: durationValue),
                              onChanged: (value) {
                                durationValue = value;
                              },
                              style: const TextStyle(fontSize: 14),
                              minLines: 3,
                              maxLines: 10,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: staticComponents
                                  .getMiddleInputDecoration('Agregar texto'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // getPrescriptionButtons()
                          ],
                        ),
                      ),
                      getMedicationButtons()
                    ],
                  )))),
    );

    /* GestureDetector(
        onTap: () {

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
    getPrescriptionButtons()*/
  }

  Widget getAlimentationView() {
    return Container(
      width: double.infinity,
      height: 470,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Peso",
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)))
                    ],
                  ),
                  sizedBox10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Flexible(
                        child: SizedBox(
                            height: durationError ? 55 : 35,
                            width: 111,
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value == '') {
                                  setState(() {
                                    durationError = true;
                                  });
                                  return "Complete el campo";
                                }
                                setState(() {
                                  durationError = false;
                                });
                              },
                              controller:
                                  TextEditingController(text: durationValue),
                              onChanged: (value) {
                                durationValue = value;
                              },
                              style: const TextStyle(fontSize: 14),
                              decoration: staticComponents
                                  .getMiddleInputDecoration('56'),
                            )),
                      ),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Kg',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF999999)),
                          ))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Estatura",
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)))
                    ],
                  ),
                  sizedBox10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Flexible(
                        child: SizedBox(
                            height: durationError ? 55 : 35,
                            width: 111,
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value == '') {
                                  setState(() {
                                    durationError = true;
                                  });
                                  return "Complete el campo";
                                }
                                setState(() {
                                  durationError = false;
                                });
                              },
                              controller:
                                  TextEditingController(text: durationValue),
                              onChanged: (value) {
                                durationValue = value;
                              },
                              style: const TextStyle(fontSize: 14),
                              decoration: staticComponents
                                  .getMiddleInputDecoration('1.65'),
                            )),
                      ),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'm',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF999999)),
                          ))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("IMC ",
                          style: TextStyle(
                              fontSize: 14, color: Color(0xff999999))),
                      Icon(Icons.info, size: 18, color: Color(0xff999999))
                    ],
                  ),
                  sizedBox10,
                  SizedBox(
                      height: durationError ? 55 : 35,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value == '') {
                            setState(() {
                              durationError = true;
                            });
                            return "Complete el campo";
                          }
                          setState(() {
                            durationError = false;
                          });
                        },
                        controller: TextEditingController(text: durationValue),
                        onChanged: (value) {
                          durationValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration:
                            staticComponents.getMiddleInputDecoration('17.9'),
                      )),
                  sizedBox10,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Alimentación ",
                          style: TextStyle(
                              fontSize: 14, color: Color(0xff999999))),
                      Icon(Icons.info, size: 18, color: Color(0xff999999))
                    ],
                  ),
                  sizedBox10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 40),
                            onPressed: () {},
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 30,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          width: 150,
                          child: Text("Verduras",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xff999999)))),
                      const SizedBox(height: 10),
                      SizedBox(
                          height: 35,
                          width: 14,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 14),
                            onPressed: () {},
                            icon: const Icon(Icons.edit,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 30),
                            onPressed: () {},
                            icon: const Icon(Icons.delete,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          ))
                    ],
                  ),
                  getButtonAddFoodOrList(),
                  sizedBox10,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Alimentos no permitidos",
                          style: TextStyle(
                              fontSize: 14, color: Color(0xff999999))),
                    ],
                  ),
                  sizedBox10,
                  getButtonAddFoodOrListProhibited(),
                  getAlimentationButtons()
                ],
              ))),
    );
  }

  Widget getPhisicalActivityView() {
    return Container(
      width: double.infinity,
      height: 470,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Rutina física ",
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)))
                    ],
                  ),
                  sizedBox10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 40),
                            onPressed: () {},
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 30,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          width: 150,
                          child: Text("Correr",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xff999999)))),
                      const SizedBox(height: 10),
                      SizedBox(
                          height: 35,
                          width: 14,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 14),
                            onPressed: () {},
                            icon: const Icon(Icons.edit,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 30),
                            onPressed: () {},
                            icon: const Icon(Icons.delete,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          ))
                    ],
                  ),
                  getButtonAddRoutineOrList(),
                  sizedBox10,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Alimentos no permitidos",
                          style: TextStyle(
                              fontSize: 14, color: Color(0xff999999))),
                    ],
                  ),
                  sizedBox10,
                  getButtonAddProhibitedRoutineOrList(),
                  getActivityButtons()
                ],
              ))),
    );
  }

  Widget getOthersView() {
    return Container(
      width: double.infinity,
      height: 470,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Insulina ",
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)))
                    ],
                  ),
                  sizedBox10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 40),
                            onPressed: () {},
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 30,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          width: 150,
                          child: Text("Nombre",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xff999999)))),
                      const SizedBox(height: 10),
                      SizedBox(
                          height: 35,
                          width: 14,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 14),
                            onPressed: () {},
                            icon: const Icon(Icons.edit,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 30),
                            onPressed: () {},
                            icon: const Icon(Icons.delete,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          ))
                    ],
                  ),
                  getButtonAddRoutineOrList(),
                  const SizedBox(height: 2),
                  getSelectOtherName(),
                  getOthersButtons()
                ],
              ))),
    );
  }

  getButtonAddFoodOrList() {
    bool conditionToShowButton = false;
    return conditionToShowButton
        ? GestureDetector(
            onTap: () {
              //show add
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xffD9D9D9),
                  hintText: "Agregar una nueva\n prescripción",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: durationValue),
                        onChanged: (value) {
                          durationValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Frutas',
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Carbohidratos",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                    },
                    controller: TextEditingController(text: durationValue),
                    onChanged: (value) {
                      durationValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents
                        .getMiddleInputDecoration('150-250 gramos'),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calorías máx.",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                    },
                    controller: TextEditingController(text: durationValue),
                    onChanged: (value) {
                      durationValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecoration('80 Kcal'),
                  )),
            ]));
  }

  getButtonAddFoodOrListProhibited() {
    bool conditionToShowButton = true;
    return conditionToShowButton
        ? GestureDetector(
            onTap: () {
              //show add
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xffD9D9D9),
                  hintText: "Agregar alimento",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: durationValue),
                        onChanged: (value) {
                          durationValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Frutas',
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Carbohidratos",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                    },
                    controller: TextEditingController(text: durationValue),
                    onChanged: (value) {
                      durationValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents
                        .getMiddleInputDecoration('150-250 gramos'),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calorías máx.",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                    },
                    controller: TextEditingController(text: durationValue),
                    onChanged: (value) {
                      durationValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecoration('80 Kcal'),
                  )),
            ]));
  }

  getButtonAddRoutineOrList() {
    bool conditionToShowButton = false;
    return conditionToShowButton
        ? GestureDetector(
            onTap: () {
              //show add
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xffD9D9D9),
                  hintText: "Agregar rutina física",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: durationValue),
                        onChanged: (value) {
                          durationValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Caminar',
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              sizedBox10,
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              child: const Text(
                                'L',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: Colors.white,
                              child: const Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              child: const Text(
                                'I',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                  ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tiempo",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Flexible(
                    child: SizedBox(
                        height: durationError ? 55 : 35,
                        width: 100,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              setState(() {
                                durationError = true;
                              });
                              return "Complete el campo";
                            }
                            setState(() {
                              durationError = false;
                            });
                          },
                          controller:
                              TextEditingController(text: durationValue),
                          onChanged: (value) {
                            durationValue = value;
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration:
                              staticComponents.getMiddleInputDecoration('3'),
                        )),
                  ),
                  SizedBox(
                      height: 35,
                      width: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: durationTypeError
                                  ? Colors.red
                                  : Color(0xFF999999),
                              width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Seleccionar',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF999999)),
                                ),
                                dropdownColor: Colors.white,
                                value: durationTypeActivityValue,
                                icon: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      end: 12.0),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xff999999)), // myIcon is a 48px-wide widget.
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    durationTypeActivityValue =
                                        newValue.toString();
                                  });
                                },
                                items: durationsActivityList.map((String item) {
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
                      ))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Periodicidad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: stateError ? Colors.red : Color(0xFF999999),
                      width: 1),
                  borderRadius: BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
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
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF999999)),
                        ),
                        dropdownColor: Colors.white,
                        value: periodicityValue,
                        icon: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Color(
                                  0xff999999)), // myIcon is a 48px-wide widget.
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            periodicityValue = newValue.toString();
                          });
                        },
                        items: periodicityList.map((String item) {
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
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calorías",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                    },
                    controller: TextEditingController(text: durationValue),
                    onChanged: (value) {
                      durationValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecoration('15 Kcal'),
                  )),
            ]));
  }

  getButtonAddProhibitedRoutineOrList() {
    bool conditionToShowButton = true;
    return conditionToShowButton
        ? GestureDetector(
            onTap: () {
              //show add
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xffD9D9D9),
                  hintText: "Agregar rutina física",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller: TextEditingController(text: durationValue),
                        onChanged: (value) {
                          durationValue = value;
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Caminar',
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      )),
                  Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
                ],
              ),
              sizedBox10,
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              child: const Text(
                                'L',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: Colors.white,
                              child: const Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              child: const Text(
                                'I',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                  ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tiempo",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Flexible(
                    child: SizedBox(
                        height: durationError ? 55 : 35,
                        width: 100,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              setState(() {
                                durationError = true;
                              });
                              return "Complete el campo";
                            }
                            setState(() {
                              durationError = false;
                            });
                          },
                          controller:
                              TextEditingController(text: durationValue),
                          onChanged: (value) {
                            durationValue = value;
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration:
                              staticComponents.getMiddleInputDecoration('3'),
                        )),
                  ),
                  SizedBox(
                      height: 35,
                      width: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: durationTypeError
                                  ? Colors.red
                                  : Color(0xFF999999),
                              width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Seleccionar',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF999999)),
                                ),
                                dropdownColor: Colors.white,
                                value: durationTypeActivityValue,
                                icon: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      end: 12.0),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xff999999)), // myIcon is a 48px-wide widget.
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    durationTypeActivityValue =
                                        newValue.toString();
                                  });
                                },
                                items: durationsActivityList.map((String item) {
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
                      ))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Periodicidad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: stateError ? Colors.red : Color(0xFF999999),
                      width: 1),
                  borderRadius: BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
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
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF999999)),
                        ),
                        dropdownColor: Colors.white,
                        value: periodicityValue,
                        icon: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Color(
                                  0xff999999)), // myIcon is a 48px-wide widget.
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            periodicityValue = newValue.toString();
                          });
                        },
                        items: periodicityList.map((String item) {
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
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calorías",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                    },
                    controller: TextEditingController(text: durationValue),
                    onChanged: (value) {
                      durationValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecoration('15 Kcal'),
                  )),
            ]));
  }

  getSelectOtherName() {
    bool conditionToShowButton = false;
    return conditionToShowButton
        ? GestureDetector(
            onTap: () {
              //show add
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    prefixIcon: Icon(Icons.circle, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xffD9D9D9),
                    hintText: "Seleccionar nombre",
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    focusedBorder: borderGray,
                    border: borderGray,
                    enabledBorder: borderGray,
                    suffixIcon: Icon(Icons.keyboard_arrow_down))))
        : Container(
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: [
                TextField(
                    minLines: 1,
                    maxLines: 10,
                    enabled: false,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        prefixIcon: Icon(
                          Icons.circle,
                          color: Color(0xff999999),
                        ),
                        filled: true,
                        fillColor: Color(0xffD9D9D9),
                        hintText: "Seleccionar nombre",
                        hintStyle: const TextStyle(
                            fontSize: 14, color: Color(0xFF999999)),
                        focusedBorder: borderGray,
                        border: borderGray,
                        enabledBorder: borderGray,
                        suffixIcon: Icon(Icons.keyboard_arrow_down))),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: otherNamesList.length,
                      //  padding: EdgeInsets.only(bottom: 60),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // on click
                          },
                          child: SizedBox(
                            height: 42,
                            child: TextField(
                                enabled: false,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF999999)),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                  prefixIcon: Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xffD9D9D9),
                                  hintText: otherNamesList[index],
                                  hintStyle: const TextStyle(
                                      fontSize: 14, color: Color(0xFF999999)),
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                )),
                          ),
                        );
                      }),
                )
              ],
            ));
  }

  getOthersButtons() {
    return isDoctorView
        ? Container(
            height: 190,
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
                          onPressed: validateAndSave,
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              'Cancelar',
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
}
