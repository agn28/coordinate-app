import 'package:flutter/material.dart';
import 'package:nhealth/concept-manager/concept_manager.dart';
import 'package:nhealth/screens/forgot_password_screen.dart';
import '../constants/constants.dart';
import 'home_screen.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      resizeToAvoidBottomInset: false,

      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 60),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 100,),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Image.asset('assets/images/logo_nhealth_horizontal.png', width: 220,),
                        Container(
                          padding: EdgeInsets.only(top: 30, left: 30),
                          child: Text('Coordinate', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w500, fontFamily: 'Roboto')),
                        )
                      ],
                    )
                  ),
                  SizedBox(height: 70,),
                  Container(
                    child: Text('Login to Continue', style: TextStyle(color: Colors.white, fontSize: 35)),
                  ),
                  SizedBox(height: 60,),
                  TextField(
                    style: TextStyle(color: Colors.white, fontSize: 19.0,),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 20.0),
                      prefixIcon: new Icon(
                        Icons.email,
                        color: Color(0xFF8fb1c9),
                        size: 30,
                      ),
                      filled: true,
                      fillColor: Color(0xFF004d84),
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(width: 1, color: Colors.white),
                      ),
                      hintText: 'Email Address',
                      hintStyle: TextStyle(color: kWhite70, fontSize: 18.0),
                    ),
                  ),
                  // SizedBox(height: 5,),
                  // Text('Please input a valid email address', style: TextStyle(color: kErroText, fontSize: 16)),
                  SizedBox(height: 40,),
                  TextField(
                    obscureText: true,
                    style: TextStyle(color: Colors.white, fontSize: 19.0),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 20.0),
                      prefixIcon: new Icon(
                        Icons.vpn_key,
                        color: Color(0xFF8fb1c9),
                        size: 30,
                      ),
                      suffixIcon: Icon(
                        Icons.visibility,
                        color: Color(0xFF8fb1c9)
                      ),
                      filled: true,
                      fillColor: Color(0xFF004d84),
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(width: 1, color: Colors.white),
                      ),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: kWhite70, fontSize: 18.0),
                    ),
                  ),
                  SizedBox(height: 40,),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement( HomeScreen()),
                    child: Container(
                      width: double.infinity,
                      height: 62.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kLightButton,
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text("LOGIN", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500))
                    ),
                  ),
                  SizedBox(height: 40,),
                  FlatButton(
                    // onPressed: () => Navigator.of(context).push( ForgotPasswordScreen()),
                    onPressed: () => ConceptManager().sync(),
                    child: Text("Forgot Password?", style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w400),),
                  ),
                ],
              ),
            ),
            flex: 10,
          ),

          Expanded(
            flex: 2,
            child: Container(
              height: 200,
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/images/frame.png')
            ),
          ),
        ],
      ),
    );
  }
}
