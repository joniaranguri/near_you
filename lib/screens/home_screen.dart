import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_you/screens/login_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class MySliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double _maxExtent = 240;
  final VoidCallback onActionTap;

  MySliverHeaderDelegate({
    required this.onActionTap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                      child: Text("Hola Mundo",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                  //apply padding to all four sides
                  Text(
                    'Diabetes Typo 2',
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
                  logOut(context);
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
          'Vincular',
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
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    //final expandedHeight = MediaQuery.of(context).size.height * 0.2;
    return Stack(children: <Widget>[
      Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverPersistentHeader(
                pinned: true,
                delegate: MySliverHeaderDelegate(onActionTap: () {
                  debugPrint("on Tap");
                }),
              ),
            ];
          },
          body: CircularPercentIndicator(
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
                  Text(
                    'ADHERENCIA',
                    style: TextStyle(fontSize: 16, color: Color(0xff999999)),
                  ),
                  Text('NORMAL',
                      style: TextStyle(fontSize: 16, color: Color(0xff999999)))
                ],
              ),
              linearGradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: <Color>[Color(0xff6EC6A4), Color(0xff6EC6A4)]),
              rotateLinearGradient: true,
              circularStrokeCap: CircularStrokeCap.round),
        ),
        bottomNavigationBar: _buildBottomBar(),
        floatingActionButton: Container(
          padding: EdgeInsets.only(top: 40),
          child: SvgPicture.asset(
            'assets/images/tab_plus_selected.svg',
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    ]);
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
            setState(() {});
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
}
