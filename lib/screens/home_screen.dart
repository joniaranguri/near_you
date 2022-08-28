import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_you/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Scaffold(
          backgroundColor: Colors.white,
          body: Container(
              color: Colors.blue,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                        padding: const EdgeInsets.only(
                            left: 25, top: 50, bottom: 25),
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.asset(
                          'assets/images/log_out.svg',
                        ),
                        onPressed: () {
                          logOut();
                        }),
                  ])))
    ]);
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>  LoginScreen(),
      ),
    );
  }
}
