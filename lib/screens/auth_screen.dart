import 'package:flutter/material.dart';
import 'package:nhealth/concept-manager/concept_manager.dart';
import 'package:nhealth/controllers/auth_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/forgot_password_screen.dart';
import '../constants/constants.dart';
import 'home_screen.dart';
import 'package:nhealth/app_localizations.dart';

final emailController = TextEditingController();
final passwordController = TextEditingController();
bool _emailAutoValidate = false;
bool _passwordAutoValidate = false;
bool isLoading = false;
final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  @override
  Widget build(BuildContext context) {

    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      resizeToAvoidBottomInset: false,

      body:  useMobileLayout ? MobileAuth() : TabAuth(),
    );
  }
}

class MobileAuth extends StatefulWidget {

  @override
  _MobileAuthState createState() => _MobileAuthState();
}

bool _showPassword = true;
class _MobileAuthState extends State<MobileAuth> {

 @override
 initState() {
   super.initState();
   _showPassword = true;
 }

  _changePassowrdVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
    children: <Widget>[
      GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
              child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 80,),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Image.asset('assets/images/logo_nhealth_horizontal.png', width: 140,),
                        SizedBox(width: 15,),
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Text('Coordinate', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Roboto')),
                        )
                      ],
                    )
                  ),
                  SizedBox(height: 50,),
                  Container(
                    child: Text(AppLocalizations.of(context).translate('welcome'), style: TextStyle(color: Colors.white, fontSize: 28)),
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
                          keyboardType: TextInputType.emailAddress,
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
                                errorStyle: TextStyle(fontSize: 14.0, color: Color(0xFFFFB8B8)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                prefixIcon: new Icon(
                                  Icons.email,
                                  color: Color(0xFF8fb1c9),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: Color(0xFF004d84),
                                border: new UnderlineInputBorder(
                                  borderSide: new BorderSide(width: 1, color: Colors.white),
                                ),
                                hintText: AppLocalizations.of(context).translate('emailAddress'),
                                hintStyle: TextStyle(color: kWhite70, fontSize: 16.0),
                              ),
                            ),
                            // SizedBox(height: 5,),
                            // Text('Please input a valid email address', style: TextStyle(color: kErroText, fontSize: 16)),
                            SizedBox(height: 20,),
                            TextFormField(
                              obscureText: _showPassword,
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
                              style: TextStyle(color: Colors.white, fontSize: 14.0),
                              decoration: InputDecoration(
                                errorStyle: TextStyle(fontSize: 16.0, color: Color(0xFFFFB8B8)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                prefixIcon: new Icon(
                                  Icons.vpn_key,
                                  color: Color(0xFF8fb1c9),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _changePassowrdVisibility();
                                  },
                                  icon: Icon(
                                    Icons.visibility,
                                    color: Color(0xFF8fb1c9)
                                  ),
                                ),
                                filled: true,
                                fillColor: Color(0xFF004d84),
                                border: new UnderlineInputBorder(
                                  borderSide: new BorderSide(width: 1, color: Colors.white),
                                ),
                                hintText: AppLocalizations.of(context).translate('password'),
                                hintStyle: TextStyle(color: kWhite70, fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30,),
                      GestureDetector(
                        onTap: () async {
                          
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            var response = await AuthController().login(emailController.text, passwordController.text);
                            print('response');
                            print(response);
                            if (response == 'error') {
                              setState(() {
                                isLoading = false;
                              });
                              return Toast.show(AppLocalizations.of(context).translate('usernameOrPassword'), context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                            }
                            setState(() {
                              isLoading = false;
                            });
                            if (response['role'] == 'nurse') {
                              Navigator.of(context).pushReplacementNamed('/chwHome');
                            }
                            Navigator.of(context).pushReplacementNamed('/');
                          }

                        },
                        child: Container(
                          width: double.infinity,
                          height: 50.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: kLightButton,
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(AppLocalizations.of(context).translate('login'), style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))
                        ),
                      ),
                      SizedBox(height: 20,),
                      FlatButton(
                        onPressed: () => Navigator.of(context).push( ForgotPasswordScreen()),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text(AppLocalizations.of(context).translate('forgotPass'), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),),
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
    );
  }
}


class TabAuth extends StatefulWidget {

  @override
  _TabAuthState createState() => _TabAuthState();
}

class _TabAuthState extends State<TabAuth> {

  @override
  initState() {
    super.initState();
    _showPassword = true;
  }

  checkInternet() {
    Toast.show('You are not connected to the internet', context, duration: Toast.LENGTH_SHORT, backgroundColor: kPrimaryAmberColor, gravity:  Toast.TOP, backgroundRadius: 5);
  }
  _changePassowrdVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Stack(
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
                          child: Text(AppLocalizations.of(context).translate('coordinate'), style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w500, fontFamily: 'Roboto')),
                        )
                      ],
                    )
                  ),
                  SizedBox(height: 70,),
                  Container(
                    child: Text(AppLocalizations.of(context).translate('welcome'), style: TextStyle(color: Colors.white, fontSize: 35)),
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
                                hintText: AppLocalizations.of(context).translate('emailAddress'),
                                hintStyle: TextStyle(color: kWhite70, fontSize: 18.0),
                              ),
                            ),
                            // SizedBox(height: 5,),
                            // Text('Please input a valid email address', style: TextStyle(color: kErroText, fontSize: 16)),
                            SizedBox(height: 40,),
                            TextFormField(
                              obscureText: _showPassword,
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
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    _changePassowrdVisibility();
                                  },
                                                                child: Icon(
                                    Icons.visibility,
                                    color: Color(0xFF8fb1c9)
                                  ),
                                ),
                                filled: true,
                                fillColor: Color(0xFF004d84),
                                border: new UnderlineInputBorder(
                                  borderSide: new BorderSide(width: 1, color: Colors.white),
                                ),
                                hintText: AppLocalizations.of(context).translate('password'),
                                hintStyle: TextStyle(color: kWhite70, fontSize: 18.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40,),
                      GestureDetector(
                        onTap: () async {
                          bool isInternetAvailable = await Helpers().isInternetAvailable();
                          if (!isInternetAvailable) {
                            return Toast.show('You are not connected to the internet', context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                          }
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
                              return Toast.show(AppLocalizations.of(context).translate('usernameOrPassword'), context, duration: Toast.LENGTH_LONG, backgroundColor: kPrimaryRedColor, gravity:  Toast.BOTTOM, backgroundRadius: 5);
                            }
                            setState(() {
                              isLoading = false;
                            });
                            if (response['role'] == 'chw') {
                              Navigator.of(context).pushReplacementNamed('/chwHome');
                            } else {
                              Navigator.of(context).pushReplacementNamed('/home');
                            }
                            
                            // Navigator.of(context).pushReplacementNamed('/');
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
                          child: Text(AppLocalizations.of(context).translate('login'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500))
                        ),
                      ),
                      SizedBox(height: 40,),
                      FlatButton(
                        onPressed: () => Navigator.of(context).push( ForgotPasswordScreen()),
                        child: Text(AppLocalizations.of(context).translate('forgotPass'), style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w400),),
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
