import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:near_you/common/static_common_functions.dart';
import '../model/user.dart' as user;

import '../Constants.dart';
import '../widgets/dialogs.dart';
import '../widgets/firebase_utils.dart';
import '../widgets/static_components.dart';

class MyProfileScreen extends StatefulWidget {
  user.User? currentUser;

  MyProfileScreen(this.currentUser);

  static const routeName = '/my_profile';

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState(currentUser);
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static StaticComponents staticComponents = StaticComponents();
  user.User? currentUser;
  late final Future<DocumentSnapshot> futureUser;
  var _currentIndex = 1;

  double percentageProgress = 0;

  _MyProfileScreenState(this.currentUser);

  @override
  void initState() {
    futureUser = getUserById(FirebaseAuth.instance.currentUser!.uid);
    futureUser.then((value) => {
          setState(() {
            currentUser = user.User.fromSnapshot(value);
            //  notifier = ValueNotifier(false);
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
                  icon: Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () {
                    //
                  },
                )
              ],
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Mi Perfil',
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
                              height: 180,
                              width: double.maxFinite,
                              child: Container(
                                color: Color(0xff2F8F9D),
                                child: Column(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xff7c94b6),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                'http://i.imgur.com/QSev0hg.jpg'),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50.0)),
                                          border: Border.all(
                                            color: Color(0xff47B4AC),
                                            width: 4.0,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/images/person_default.png',
                                          height: 90,
                                        )),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            currentUser?.fullName ?? "Nombre",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        ]),
                                    FlatButton(
                                      height: 20,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: 30,
                                          right: 30,
                                          top: 5,
                                          bottom: 5),
                                      color: Colors.white,
                                      onPressed: () {
                                        if (getVinculationCondition()) {
                                          showDialogVinculation(
                                              currentUser!.fullName??"Nombre",currentUser!.email!,
                                              context,
                                              currentUser!.isPatiente(),
                                              (){},
                                              successPendingVinculation);
                                        } else {
                                          startDevinculation();
                                        }
                                      },
                                      child: Text(
                                        getVinculationCondition()
                                            ? 'Vincular'
                                            : 'Desvincular',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff9D9CB5)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            getScreenType(),
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
            : InkWell(
                child: Container(
                  padding: EdgeInsets.only(top: 40),
                  child:
                      SvgPicture.asset('assets/images/person_tab_selected.svg'),
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
                  'assets/images/plus_tab_unselected.svg',
                ),
                label: "")
          ],
        ),
      ),
    );
  }

  getScreenType() {
    return SizedBox(
      width: 400,
      height: 600,
      child: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[]),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )))),
                ),
              ])
          //Column
          ), //Padding
    );
  }

  void startDevinculation() {
    showDialogDevinculation(context, currentUser!.userId!, true, (){
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => MyProfileScreen(currentUser)));
    });
  }

  bool getVinculationCondition() {
    return !currentUser!.isPatiente() ||
        !isNotEmtpy(currentUser?.medicoId ?? "");
  }

  successPendingVinculation() {
    Navigator.pop(context);
    dialogWaitVinculation(context, () {
      Navigator.pop(context);
    }, currentUser!.isPatiente());
  }
}
