import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:near_you/screens/login_screen.dart';
import 'package:near_you/widgets/static_components.dart';

import '../Constants.dart';

class SignupScreen extends StatelessWidget {
  static const routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return const SignUpWidget();
  }
}

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  static StaticComponents staticComponents = StaticComponents();
  bool secondScreen = false;
  String emailValue = "";
  String passwordValue = "";
  String fullNameValue = "";
  String phoneNumberValue = "";
  String? genderValue;
  String? smokeValue;
  String ageValue = "";
  String addressValue = "";
  String medicalCenterValue = "";
  String referenceValue = "";
  String altPhoneValue = "";
  String allergiesValue = "";
  static List<String> genderList = ["Masculino", "Femenino"];
  static List<String> smokeList = ["No fumo", "Fumo"];

  String _selectedDate = '';
  final firebaseAuth.FirebaseAuth _auth = firebaseAuth.FirebaseAuth.instance;

  get inputBorder => OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffCECECE)),
      borderRadius: BorderRadius.circular(10));

  get SizeBox12 => const SizedBox(
        height: 12,
      );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 8),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _selectedDate = DateFormat.yMMMMd("en_US").format(d);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
          color: Colors.blue,
          width: double.maxFinite,
          height: double.maxFinite,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SvgPicture.asset('assets/images/backgroundLogin.svg'),
          )),
      Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(secondScreen ? Icons.arrow_back : null, color:Color(0xffCECECE)),
              onPressed: () {
                setState(() {
                  secondScreen = false;
                });
              },
            ),
          ),
          backgroundColor: Colors.transparent,
          body: secondScreen ? getSecondScreen() : getFirstScreen())
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
                  SizedBox(
                    height: 50,
                  ),
                  const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff333333),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: TextEditingController(text: emailValue),
                    onChanged: (value) {
                      emailValue = value;
                    },
                    style: TextStyle(fontSize: 14),
                    decoration: staticComponents
                        .getInputDecoration('Correo Electrónico'),
                  ),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: passwordValue),
                    onChanged: (value) {
                      passwordValue = value;
                    },
                    obscureText: true,
                    style: TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getInputDecoration('Contraseña'),
                  ),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: fullNameValue),
                    onChanged: (value) {
                      fullNameValue = value;
                    },
                    style: TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getInputDecoration('Nombre Completo'),
                  ),
                  SizeBox12,
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _selectedDate),
                    onTap: () {
                      _selectDate(context);
                    },
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today,
                              color: Color(0xffCECECE)),
                        ), // myIcon is a 48px-wide widget.
                      ),
                      fillColor: Colors.white,
                      hintText: 'Fecha de nacimiento',
                      hintStyle: const TextStyle(
                          fontSize: 14, color: Color(0xffCECECE)),
                      contentPadding: const EdgeInsets.all(15),
                      enabledBorder: staticComponents.inputBorder,
                      border: staticComponents.inputBorder,
                    ),
                  ),
                  SizeBox12,
                  TextField(
                      controller: TextEditingController(text: phoneNumberValue),
                      onChanged: (value) {
                        phoneNumberValue = value;
                      },
                      style: TextStyle(fontSize: 14),
                      decoration:
                          staticComponents.getInputDecoration('Teléfono')),
                  SizeBox12,
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(
                          height: 30,
                        ),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(15),
                          color: const Color(0xff3BACB6),
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              secondScreen = true;
                            });
                          },
                          child: const Text(
                            'Siguiente',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const <Widget>[
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
                          height: 25,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Crear una cuenta con',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff555555),
                                ),
                              )
                            ]),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 40, right: 40),
                            //apply padding to all four sides
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Color(0xffCECECE)),
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
                                      border: Border.all(
                                          width: 1, color: Color(0xffCECECE)),
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
                                      border: Border.all(
                                          width: 1, color: Color(0xffCECECE)),
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

  getSecondScreen() {
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
                  SizedBox(
                    height: 50,
                  ),
                  const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff333333),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                      controller: TextEditingController(text: ageValue),
                      onChanged: (value) {
                        ageValue = value;
                      },
                      style: TextStyle(fontSize: 14),
                      decoration: staticComponents.getInputDecoration('Edad')),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: addressValue),
                    onChanged: (value) {
                      addressValue = value;
                    },
                    style: TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getInputDecoration('Dirección'),
                  ),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: medicalCenterValue),
                    onChanged: (value) {
                      medicalCenterValue = value;
                    },
                    style: TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getInputDecoration('Centro Médico'),
                  ),
                  SizeBox12,
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffCECECE), width: 1),
                      borderRadius: BorderRadius.all(
                          Radius.circular(10) //         <--- border radius here
                          ),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            hint: Text(
                              'Género',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xffCECECE)),
                            ),
                            dropdownColor: Colors.white,
                            value: genderValue,
                            icon: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 12.0),
                              child: Icon(Icons.keyboard_arrow_down,
                                  color: Color(
                                      0xffCECECE)), // myIcon is a 48px-wide widget.
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                genderValue = newValue.toString();
                              });
                            },
                            items: genderList.map((String item) {
                              return DropdownMenuItem(
                                value: item,
                                child: SizedBox(height: 20, child: Text(item)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: referenceValue),
                    onChanged: (value) {
                      referenceValue = value;
                    },
                    style: TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getInputDecoration('Referencia'),
                  ),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: altPhoneValue),
                    onChanged: (value) {
                      altPhoneValue = value;
                    },
                    style: TextStyle(fontSize: 14),
                    decoration: staticComponents
                        .getInputDecoration('Teléfono alternativo'),
                  ),
                  SizeBox12,
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffCECECE), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(
                                10) //         <--- border radius here
                            ),
                      ),
                      child: Container(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              hint: Text(
                                'Tabaquismo',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xffCECECE)),
                              ),
                              dropdownColor: Colors.white,
                              value: smokeValue,
                              icon: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 12.0),
                                child: Icon(Icons.keyboard_arrow_down,
                                    color: Color(
                                        0xffCECECE)), // myIcon is a 48px-wide widget.
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  smokeValue = newValue.toString();
                                });
                              },
                              items: smokeList.map((String item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child:
                                      SizedBox(height: 20, child: Text(item)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )),
                  SizeBox12,
                  TextField(
                    controller: TextEditingController(text: allergiesValue),
                    onChanged: (value) {
                      allergiesValue = value;
                    },
                    minLines: 1,
                    maxLines: 10,
                    style: TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getInputDecoration('Alergias\n'),
                  ),
                  SizeBox12,
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(
                          height: 30,
                        ),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(15),
                          color: const Color(0xff3BACB6),
                          textColor: Colors.white,
                          onPressed: () {
                            if (isFormValid()) {
                              registerUser();
                            }else{
                              showMessageIncompleteRequired();
                            }
                          },
                          child: const Text(
                            'Registrar',
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
                        height: 80,
                      ),
                      SvgPicture.asset(
                        'assets/images/success_icon_modal.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('¡Exito!',
                          style: TextStyle(
                              fontSize: 25,
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
                                // Navigator.pop(context);
                                Navigator.of(context)
                                    .pushNamed(LoginScreen.routeName);
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

  bool isFormValid() {
    return (emailValue != "" &&
        passwordValue != "" &&
        emailValue.contains("@") &&
        passwordValue.length >= 6);
  }

  registerUser() async {
    _auth
        .createUserWithEmailAndPassword(
      email: emailValue,
      password: passwordValue,
    )
        .then((result) {
      firebaseAuth.User? user = result.user;
      if (user != null) {
        saveUserDataInDatabase();
         }
    }).catchError((e) {
      print(e);
    });
  }

  void showMessageIncompleteRequired() {
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
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Complete al menos \nemail y contraseña!',
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

  void saveUserDataInDatabase() {
    final db = FirebaseFirestore.instance;
    String? newUserId = FirebaseAuth.instance.currentUser?.uid;
    final userData = <String, String>{
      USER_ID_KEY: newUserId!,
      EMAIL_KEY: emailValue,
      FULL_NAME_KEY: fullNameValue,
      BIRTH_DAY_KEY: _selectedDate,
      PHONE_KEY: phoneNumberValue,
      AGE_KEY: ageValue,
      ADDRESS_KEY: addressValue,
      MEDICAL_CENTER_VALUE: medicalCenterValue,
      GENDER_KEY: genderValue.toString(),
      REFERENCE_KEY: referenceValue,
      ALT_PHONE_NUMBER_KEY: altPhoneValue,
      SMOKING_KEY: smokeValue.toString(),
      ALLERGIES_KEY: allergiesValue,
    };
    db.collection(USERS_COLLECTION_KEY).doc(newUserId).set(userData).then((_) => dialogSuccess());
  }
}
