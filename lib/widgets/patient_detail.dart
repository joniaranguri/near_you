import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../widgets/grouped_bar_chart.dart';
import '../model/user.dart' as user;

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
  PatientDetailState createState() => PatientDetailState(this.detailedUser);

}

class PatientDetailState extends State<PatientDetail> {
  user.User? detailedUser;
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  PatientDetailState(this.detailedUser);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 580,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: 2,
          itemBuilder: (ctx, i) => getCurrentPageByIndex(ctx, i)
      ),
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
    if(i !=0)
      return Text("Hello world");

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
}
