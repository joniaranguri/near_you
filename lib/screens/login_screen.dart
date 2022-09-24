import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/screens/home_screen.dart';
import 'package:near_you/screens/role_selection_screen.dart';
import 'package:near_you/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/static_components.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginWidget();
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool showSelectRole = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefValue) => {
          setState(() {
            showSelectRole = !prefValue.containsKey(SHOW_ROLE_SELECTION);
            prefValue.setString(SHOW_ROLE_SELECTION, SHOW_ROLE_SELECTION);
          })
        });
  }

  static StaticComponents staticComponents = StaticComponents();
  String emailValue = "";
  String passwordValue = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get inputBorder => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffCECECE)),
      borderRadius: BorderRadius.circular(10));

  get SizeBox12 => const SizedBox(
        height: 12,
      );

  @override
  Widget build(BuildContext context) {
    //return GettingStartedScreen();
    return Stack(children: <Widget>[
      Container(
          color: Colors.blue,
          width: double.maxFinite,
          height: double.maxFinite,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SvgPicture.asset('assets/images/backgroundLogin.svg'),
          )),
      Scaffold(backgroundColor: Colors.transparent, body: getFirstScreen())
    ]);
  }

  getFirstScreen() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
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
                  const SizedBox(
                    height: 200,
                  ),
                  const Text(
                    "Iniciar Sesion",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff333333),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.center, children: const <Widget>[
                    Text(
                      'Inicia sesión con una cuenta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff555555),
                      ),
                    )
                  ]),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      //apply padding to all four sides
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 1, color: const Color(0xffCECECE)),
                                borderRadius: BorderRadius.circular(5),
                                shape: BoxShape.rectangle),
                            child: IconButton(
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(),
                                icon: SvgPicture.asset(
                                  'assets/images/facebookLogin.svg',
                                ),
                                onPressed: () {
                                  //do something,
                                }),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 1, color: const Color(0xffCECECE)),
                                borderRadius: BorderRadius.circular(5),
                                shape: BoxShape.rectangle),
                            child: IconButton(
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(),
                                icon: SvgPicture.asset(
                                  'assets/images/googleLogin.svg',
                                ),
                                onPressed: () {
                                  //do something,
                                }),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 1, color: const Color(0xffCECECE)),
                                borderRadius: BorderRadius.circular(5),
                                shape: BoxShape.rectangle),
                            child: IconButton(
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(),
                                icon: SvgPicture.asset(
                                  'assets/images/instagramLogin.svg',
                                ),
                                onPressed: () {
                                  //do something,
                                }),
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const <Widget>[
                    Expanded(
                        child: Divider(
                      color: Color(0xffCECECE),
                      thickness: 1,
                    )),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      //apply padding to all four sides
                      child: Text(
                        'o',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffCECECE),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      color: Color(0xffCECECE),
                      thickness: 1,
                    )),
                  ]),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: TextEditingController(text: emailValue),
                    onChanged: (value) {
                      emailValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getInputDecoration('Correo Electrónico'),
                  ),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: passwordValue),
                    onChanged: (value) {
                      passwordValue = value;
                    },
                    obscureText: true,
                    style: const TextStyle(fontSize: 14),
                    decoration: staticComponents.getInputDecoration('Contraseña'),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
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
                        _signInWithEmailAndPassword();
                      },
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizeBox12,
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: Color(0xff9D9CB5), width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(15),
                      textColor: const Color(0xff9D9CB5),
                      onPressed: () {
                        Navigator.of(context).pushNamed(SignupScreen.routeName);
                      },
                      child: const Text(
                        'Registrarme',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _signInWithEmailAndPassword() async {
    final User? user = (await _auth.signInWithEmailAndPassword(
      //email: 'yeisson@medico.com',
      //password: '12345678',
      email: emailValue,
      password: passwordValue, 
    ))
        .user;

    if (user != null) {
      SharedPreferences.getInstance().then((prefValue) => {
            setState(() {
              showSelectRole = !prefValue.containsKey(user.uid);
              prefValue.setString(user.uid, user.uid);
            })
          });
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => getScreenAfterLogin(),
        ),
      );
    } else {
      showMessageErrorLogin();
    }
  }

  void showMessageErrorLogin() {
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
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      SvgPicture.asset(
                        'assets/images/warning_icon.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('¡Error!',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Email o contraseña inválidos!',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
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
                      ])
                    ],
                  ))
            ])
          ],
        );
      },
    );
  }

  getScreenAfterLogin() {
    if (showSelectRole) {
      return RoleSelectionScreen();
    } else {
      return HomeScreen();
    }
  }
}
