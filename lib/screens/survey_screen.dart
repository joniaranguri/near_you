import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:near_you/common/survey_static_values.dart';

import '../Constants.dart';

class SurveyScreen extends StatefulWidget {
  String userId;
  String userName;

  SurveyScreen(this.userId, this.userName);

  static const routeName = '/survey';

  @override
  _SurveyScreenState createState() => _SurveyScreenState(userId, userName);
}

class _SurveyScreenState extends State<SurveyScreen> {
  static List<SurveyData> surveyList = <SurveyData>[];
  static List<String?> surveyResults = List.filled(surveyList.length, '0');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userId;
  String userName;
  late final Future<List<SurveyData>> futureSurvey;
  var _currentIndex = 1;

  double percentageProgress = 0;

  _SurveyScreenState(this.userId, this.userName);

  @override
  void initState() {
    futureSurvey = getSurveyQuestions();
    futureSurvey.then((value) => {
          setState(() {
            surveyList = value;
            surveyResults = List.filled(surveyList.length, null);
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
              actions: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    //
                  },
                )
              ],
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Encuestas',
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
                              future: futureSurvey,
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
    if (surveyList.isEmpty) {
      return noSurveyView();
    }
    return SizedBox(
      width: 400,
      height: 600,
      child: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
                  Widget>[
            GFProgressBar(
              percentage: percentageProgress,
              lineHeight: 17,
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  (100 * percentageProgress).toInt().toString() + '%',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              backgroundColor: Color(0xffD9D9D9),
              progressBarColor: Color(0xff2F8F9D),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(
                'Hola ' + userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2F8F9D),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      "Tienes una encuesta pendiente",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ]),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: surveyList.length,
                                      itemBuilder: (context, index) {
                                        return Column(children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Flexible(
                                                  child: Text(
                                                surveyList[index].question,
                                                style: TextStyle(
                                                    color: Color(0xff67757F),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ))
                                            ],
                                          ),
                                          SizedBox(
                                            child: ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: surveyList[index]
                                                    .options
                                                    .length,
                                                itemBuilder: (context, i) {
                                                  return ListTile(
                                                      dense: true,
                                                      leading: Radio<String>(
                                                        visualDensity:
                                                            const VisualDensity(
                                                          horizontal:
                                                              VisualDensity
                                                                  .minimumDensity,
                                                          vertical: VisualDensity
                                                              .minimumDensity,
                                                        ),
                                                        fillColor:
                                                            MaterialStateProperty
                                                                .resolveWith<
                                                                    Color>((Set<
                                                                        MaterialState>
                                                                    states) {
                                                          return Color(
                                                              0xff999999);
                                                        }),
                                                        value: (surveyList[
                                                                        index]
                                                                    .options
                                                                    .length -
                                                                i -
                                                                1)
                                                            .toString(),
                                                        groupValue:
                                                            surveyResults[
                                                                index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            surveyResults[
                                                                index] = value!;
                                                            int currentTotal =
                                                                0;
                                                            for (int j = 0;
                                                                j <
                                                                    surveyResults
                                                                        .length;
                                                                j++) {
                                                              if (surveyResults[
                                                                      j] !=
                                                                  null) {
                                                                currentTotal++;
                                                              }
                                                            }
                                                            percentageProgress =
                                                                currentTotal /
                                                                    surveyResults
                                                                        .length;
                                                          });
                                                        },
                                                      ),
                                                      title: Text(
                                                        (surveyList[index]
                                                                        .options
                                                                        .length -
                                                                    i)
                                                                .toString() +
                                                            ".- " +
                                                            surveyList[index]
                                                                .options[i],
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff67757F),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ));
                                                }),
                                          ),
                                          SizedBox(height: 10)
                                        ]);
                                      })),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FlatButton(
                                    disabledColor: Color(0xffD9D9D9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    color: const Color(0xff2F8F9D),
                                    textColor: Colors.white,
                                    onPressed: percentageProgress == 1
                                        ? saveAndGoBack
                                        : null,
                                    child: const Text(
                                      'Enviar',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )))),
            ),
          ])
          //Column
          ), //Padding
    );
  }

  Future<List<SurveyData>> getSurveyQuestions() async {
    return StaticSurvey.surveyStaticList;
  }

  noSurveyView() {
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
                  'Ya has completado  \nla encuesta',
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
                const SizedBox(
                  height: 10,
                ),
              ])),
    );
  }

  void saveAndGoBack() {
    final db = FirebaseFirestore.instance;
    final data = <String, String>{};
    for (int i = 0; i < surveyResults.length; i++) {
      data.putIfAbsent((i + 1).toString(), () => surveyResults[i]!);
    }
    db
        .collection(USERS_COLLECTION_KEY)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(SURVEY_COLLECTION_KEY)
        .add(data)
        .then((value) => dialogSuccess());
  }

  void dialogSuccess() {
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
                        height: 10,
                      ),
                      SvgPicture.asset(
                        'assets/images/success_icon_modal.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Encuesta\n completada',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                          '¡Gracias por completar el\nprogreso de su adherencia',
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
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Aceptar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
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
