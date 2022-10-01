import 'package:flutter/material.dart';

import '../model/slide.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/slide_dots.dart';
import '../widgets/slide_item.dart';

class GettingStartedScreen extends StatefulWidget {
  static const routeName = '/getting_started';

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            const Circles1(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SlideItem(0),
                  /*  PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: slideList.length,
                      itemBuilder: (ctx, i) => SlideItem(i),
                    ),
                    Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(bottom: 35),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for(int i = 0; i<slideList.length; i++)
                                if( i == _currentPage )
                                  SlideDots(true)
                                else
                                  SlideDots(false)
                            ],
                          ),
                        )
                      ],
                    ), */
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(15),
                        color: const Color(0xff3BACB6),
                        textColor: Colors.white,
                        onPressed: () {
                          onClickStart();
                        },
                        child: const Text(
                          'Empezar',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            //apply padding to all four sides
                            child: Text(
                              'Ya tengo una cuenta',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          LoginButton()
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onClickStart() {
    if (_currentPage < 2) {
      _currentPage++;
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => SignupScreen()));
    }

    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text(
                'Iniciar Sesion',
                style: TextStyle(fontSize: 14, color: Color(0xff3BACB6)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginScreen()));
              },
            ),
            const Text(
              'Aqui',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }
}

class Circles1 extends StatelessWidget {
  const Circles1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SvgPicture.asset('assets/images/backgroundLogin.svg',
          fit: BoxFit.fill),
    );
  }
}

class TreatmentAdherenceDesign extends StatelessWidget {
  const TreatmentAdherenceDesign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 200,
            width: 273,
            child: SvgPicture.asset('assets/images/logo.svg')),
        SizedBox(
          width: 300,
          height: 60,
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff555555),
                  fontWeight: FontWeight.w500,
                ),
                children: <TextSpan>[
                  TextSpan(text: 'Monitorea '),
                  TextSpan(
                      text: 'el seguimiento a la adherencia con ',
                      style: TextStyle(color: Color(0xff2F8F9D))),
                  TextSpan(text: 'una rutina diaria.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
