import 'package:flutter/material.dart';
import 'package:nhealth/concept-manager/concept_manager.dart';
import 'package:nhealth/controllers/auth_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/forgot_password_screen.dart';
import '../constants/constants.dart';
import 'home_screen.dart';
import 'package:nhealth/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _emailAutoValidate = false;
  bool _passwordAutoValidate = false;
  bool isLoading = false;


  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      resizeToAvoidBottomInset: false,

      body:  Stack(
      children: <Widget>[
        Column(
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
                    child: Text('Welcome', style: TextStyle(color: Colors.white, fontSize: 35)),
                    // child: Text(AppLocalizations.of(context).translate('welcome'), style: TextStyle(color: Colors.white, fontSize: 35)),
                  ),
                  SizedBox(height: 60,),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          style: TextStyle(color: Colors.white, fontSize: 19.0,),
                          controller: emailController,
                          autovalidate: _emailAutoValidate,
                          onChanged: (value) {
                              setState(() => _emailAutoValidate = true);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Email is required';
                            } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                              return 'This is not a valid email address';
                            }

                                return null;
                              },
                              decoration: InputDecoration(
                                errorStyle: TextStyle(fontSize: 16.0, color: Color(0xFFFFB8B8)),
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
                            TextFormField(
                              obscureText: true,
                              controller: passwordController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                              autovalidate: _passwordAutoValidate,
                              onChanged: (value) {
                                  setState(() => _passwordAutoValidate = true);
                              },
                              style: TextStyle(color: Colors.white, fontSize: 19.0),
                              decoration: InputDecoration(
                                errorStyle: TextStyle(fontSize: 16.0, color: Color(0xFFFFB8B8)),
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
                          ],
                        ),
                      ),
                      SizedBox(height: 40,),
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            var response = await AuthController().login(emailController.text, passwordController.text);
                            if (response == 'error') {
                              setState(() {
                                isLoading = false;
                              });
                              return Toast.show('Username or password is not correct', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                            }
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
                          }

                        },
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
                        onPressed: () => Navigator.of(context).push( ForgotPasswordScreen()),
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
          isLoading ? Container(
            height: double.infinity,
            width: double.infinity,
            color: Color(0x20FFFFFF),
            child: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),backgroundColor: Color(0x30FFFFFF),)
            ),
          ) : Container(),
        ]
      ),
    );
  }
}
