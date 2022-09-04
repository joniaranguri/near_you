import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/widgets/patient_detail.dart';

class ListViewHomeLayout extends StatefulWidget {
  @override
  ListViewHome createState() {
    return new ListViewHome();
  }
}

class ListViewHome extends State<ListViewHomeLayout> {
  List<Treatment> treatments = [
    Treatment(userId: "0jtMapJzMfQ5miwcKSqd2oY8ZgX2", fullName: "Pepito Perez", adherenceLevel: 85),
    Treatment(userId: "344334", fullName: "Vanessa Hudgens", adherenceLevel: 65),
    Treatment(userId: "344334", fullName: "Fito Paez", adherenceLevel: 29),
    Treatment(userId: "344334", fullName: "Lionel Messi", adherenceLevel: 95)
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: treatments.length,
        padding: EdgeInsets.only(bottom: 60),
        itemBuilder: (context, index) {
          return InkWell(onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetailScreen(treatments[index].userId),
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
                              padding: const EdgeInsets.only(left: 12, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      treatments[index].fullName??"Nombre",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    ),
                                    FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "•  1 Tratamiento",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff67757F),
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                              const EdgeInsets.only(left: 20),
                                              child: Text(
                                                " •  3Prescripción",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color(0xff67757F),
                                                ),
                                              )),
                                          Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  "•  Nivel de adherencia: ",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight.normal,
                                                    color: Color(0xff67757F),
                                                  ),
                                                ),
                                                Text(
                                                  (treatments[index].adherenceLevel??0).toString() +"%",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: getAdherenceLevelColor(index),
                                                  ),
                                                )
                                              ]),
                                        ]),
                                    Padding(
                                        padding: const EdgeInsets.only(right: 25),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: SvgPicture.asset(
                                                'assets/images/unlink_icon.svg')))
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

  getAdherenceLevelColor(int index) {
    var value = 0xff47B4AC;
    int adherenceLevel = treatments[index].adherenceLevel??0;
    if(adherenceLevel<=33){
      value = 0xffF8191E;
    }else if(adherenceLevel<= 66){
      value = 0xffFFCC4D;
    }
    return Color(value);
  }
}
