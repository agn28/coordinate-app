import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';
import 'package:nhealth/screens/settings/settings_screen.dart';
import 'package:nhealth/app_localizations.dart';


class ChwHomeScreen extends StatefulWidget {
  @override
  _ChwHomeState createState() => _ChwHomeState();
}

class _ChwHomeState extends State<ChwHomeScreen> {
  String userName = '';
  String role = '';
  @override
  initState() {
    _getAuthData();
    super.initState();
  }
  

  _getAuthData() async {
    var data = await Auth().getStorageAuth();
    if (!data['status']) {
      Helpers().logout(context);
    }
    // Navigator.of(context).pushNamed('/login',);
    setState(() {
      userName = data['name'];
      role = data['role'];
    });
  }

  getRole(role) {
    if (role == 'chw') {
      return 'Community Health Worker';
    }

    return StringUtils.capitalize(role);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('home'), style: TextStyle(color: Colors.white, fontSize: 22),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 60,),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.perm_identity, size: 40, color: Colors.black54,),
                  ),
                  SizedBox(height: 30,),
                  Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                  Text(role != null ? StringUtils.capitalize(role) : '', style: TextStyle(fontSize: 17, height: 1.8),),
                  GestureDetector(
                    onTap: () {},
                    child: Text(AppLocalizations.of(context).translate('gotoProfile'), style: TextStyle(fontSize: 17, height: 2.5, color: kPrimaryColor),),
                  )
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.black26)
                )
              ),
            ),
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.only(left: 10, right: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    color: kLightPrimaryColor,
                    height: 50,
                    child: FlatButton(
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.home, color: kPrimaryColor,),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('home'),style: TextStyle( fontSize: 18,fontWeight: FontWeight.w500, color: kPrimaryColor))
                        ],
                      )
                    )
                  ),
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.black26)
                )
              ),
            ),

            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.only(left: 10, right: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () => Navigator.of(context).push(SettingsScreen()),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.settings, color: Colors.black54),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('settings'),style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () async {
                        Helpers().logout(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.exit_to_app, color: Colors.black54),
                          SizedBox(width: 20,),
                          Text(AppLocalizations.of(context).translate('logout'), style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400))
                        ],
                      )
                    )
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 18),
                    child: Row(
                      children: <Widget>[
                        Text(AppLocalizations.of(context).translate("version") + '0.0.8.2 (beta)', style: TextStyle( fontSize: 18, fontWeight: FontWeight.w400)),
                      ],
                    )
                  )
                ],
              )
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: 360,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_home.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 70, top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Text(AppLocalizations.of(context).translate('welcome'), style: TextStyle(color: Colors.white70, fontSize: 18),),
                        SizedBox(height: 15,),
                        Text(userName, style: TextStyle(color: Colors.white, fontSize: 24),),
                        SizedBox(height: 15,),
                        Text(role != null ? getRole(role) : '', style: TextStyle(color: Colors.white70, fontSize: 16),),
                        SizedBox(height: 40,),
                        
                        Text(AppLocalizations.of(context).translate('homeIntro'), style: TextStyle(color: Colors.white, fontSize: 34),)
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 25, right: 25),
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        
                        SizedBox(height: 60,),

                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                
                                onTap: () async {
                                  // await Auth().isExpired();
                                  // return;
                                  Navigator.of(context).pushNamed('/chwNavigation',);
                                  // Navigator.of(context).push(PatientSearchScreen());
                                },
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('assets/images/icons/inventory.png', width: 50,),
                                        SizedBox(height: 15,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate('gotoMyWorklist'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),
                                            
                                          ],
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.of(context).pushNamed('/chwNavigation', arguments: 1),
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Card(
                                    elevation: 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.group, color: kPrimaryColor, size: 60),
                                        SizedBox(height: 10,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            
                                            Text(AppLocalizations.of(context).translate('allRegistered'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),
                                            
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        
                        
                        SizedBox(height: 20,),

                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(RegisterPatientScreen()),
                                child: Container(
                                  height: 140,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 2,
                                    child: Column(
                                      children: <Widget>[
                                        Icon(Icons.person_add_alt_1, color: kPrimaryColor, size: 70,),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate('newRegistration'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.of(context).pushNamed('/chwReferralPatients'),
                                child: Container(
                                  height: 140,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Card(
                                    elevation: 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('assets/images/icons/questionnaire.png'),
                                        SizedBox(height: 10,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(AppLocalizations.of(context).translate('referralList'), textAlign: TextAlign.right, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20,),

                        

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.height, size.width / 2);
    path.lineTo(size.width, 0.0);
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
