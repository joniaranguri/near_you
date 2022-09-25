import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:near_you/screens/home_screen.dart';
import 'package:near_you/screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/getting_started_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import 'Constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool showIntroSlide = !pref.containsKey(SHOW_INTRO_SLIDE);
  pref.setString(SHOW_INTRO_SLIDE, SHOW_INTRO_SLIDE);
  runApp(MyApp(showIntroSlide));
  //runApp(DevicePreview(builder: (_) => MyApp(showIntroSlide)));
}

class MyApp extends StatelessWidget {
  final bool showIntro;

  const MyApp(this.showIntro, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Near you',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: getHome(showIntro),
      
      routes: {
        HomeScreen.routeName: (ctx) => HomeScreen(),
        GettingStartedScreen.routeName: (ctx) => GettingStartedScreen(),
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        SignupScreen.routeName: (ctx) => SignupScreen(),
        RoleSelectionScreen.routeName: (ctx) => RoleSelectionScreen(),
      },
    );
  }

  getHome(bool showIntro) {
    if (showIntro) {
      return GettingStartedScreen();
    } else if (FirebaseAuth.instance.currentUser == null) {
      return const LoginScreen();
    }
    return HomeScreen();
  }
}
