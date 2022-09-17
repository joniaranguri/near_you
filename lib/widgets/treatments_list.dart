import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/screens/patient_detail_screen.dart';
import 'package:near_you/widgets/dialogs.dart';
import '../model/user.dart' as user;

import '../Constants.dart';
import '../screens/home_screen.dart';

class ListViewHomeLayout extends StatefulWidget {
  @override
  ListViewHome createState() {
    return new ListViewHome();
  }
}

class ListViewHome extends State<ListViewHomeLayout> {
  List<user.User> patients = <user.User>[];

  late final Future<List<user.User>> patientsListFuture;

  @override
  void initState() {
    patientsListFuture = getListOfPatients();
    patientsListFuture.then((value) => {
          if (this.mounted)
            {
              setState(() {
                patients = value;
              })
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: patientsListFuture,
        builder: (context, AsyncSnapshot<List<user.User>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
                itemCount: patients.length,
                padding: EdgeInsets.only(bottom: 60),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PatientDetailScreen(patients[index].userId ?? ""),
                        ),
                      );
                    },
                    child: Card(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: ClipPath(
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          color: Color(0xff2F8F9D), width: 5))),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, right: 12),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              patients[index].fullName ??
                                                  "Nombre",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff2F8F9D),
                                              ),
                                            ),
                                            FlatButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              height: 20,
                                              color: const Color(0xff999999),
                                              textColor: Colors.white,
                                              onPressed: () {
                                                // _signInWithEmailAndPassword();
                                              },
                                              child: Text(
                                                '#000' + index.toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          ])),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
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
                                                  Text(
                                                    "•  1 Tratamiento",
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(0xff67757F),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20),
                                                      child: Text(
                                                        " •  3Prescripción",
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                      )),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          "•  Nivel de adherencia: ",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Color(
                                                                0xff67757F),
                                                          ),
                                                        ),
                                                        Text(
                                                          (patients[index].adherenceLevel ??
                                                                      0)
                                                                  .toString() +
                                                              "%",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                getAdherenceLevelColor(
                                                                    index),
                                                          ),
                                                        )
                                                      ]),
                                                ]),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 25),
                                                child: InkWell(
                                                    onTap: () {
                                                      showDialogDevinculation(
                                                          context,
                                                          patients[index]
                                                              .userId!,
                                                          false, () {
                                                        Navigator.pop(context);
                                                        Navigator.pushReplacement(context,
                                                            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
                                                      });
                                                    },
                                                    child: Container(
                                                        width: 24,
                                                        height: 24,
                                                        child: SvgPicture.asset(
                                                            'assets/images/unlink_icon.svg'))))
                                          ]))
                                  //SizedBox
                                ],
                              )),
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3))),
                        )),
                  );
                });
          }
        });
  }

  getAdherenceLevelColor(int index) {
    var value = 0xff47B4AC;
    int adherenceLevel = int.parse(patients[index].adherenceLevel ?? "0");
    if (adherenceLevel <= 33) {
      value = 0xffF8191E;
    } else if (adherenceLevel <= 66) {
      value = 0xffFFCC4D;
    }
    return Color(value);
  }

  Future<List<user.User>> getListOfPatients() async {
    final db = FirebaseFirestore.instance;
    String? medicoId = FirebaseAuth.instance.currentUser?.uid;
    if (medicoId == null) {
      return <user.User>[];
    }
    var future = await db
        .collection(USERS_COLLECTION_KEY)
        .where(MEDICO_ID_KEY, isEqualTo: medicoId)
        .get();
    List<user.User> patients = <user.User>[];
    for (var element in future.docs) {
      user.User currentUser = user.User.fromSnapshot(element);
      currentUser.userId = element.id;
      patients.add(currentUser);
    }
    return patients;
  }
}
