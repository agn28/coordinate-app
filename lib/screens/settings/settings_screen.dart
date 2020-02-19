import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class SettingsScreen extends CupertinoPageRoute {
  SettingsScreen()
      : super(builder: (BuildContext context) => new Settings());

}

class Settings extends StatefulWidget {

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String selectedType = 'In-clinic Screening';
  final commentController = TextEditingController();
  var _languages = [];
  String _selectedLanguage = '';
  
  @override
  void initState() {
    super.initState();
    _getLanguages();
  }

  _getLanguages() {
    setState(() {
      _languages = Language().getAllLanguages();
      _selectedLanguage = Language().getLanguage();
    });
  }

  _changeType (value) async {
    Language().changeLanguage(value);
    Map langMapp = {
      "English": Locale('en', 'EN'),
      "Bengali": Locale('bn', 'BN')
    };

    MyApp.setLocale(context, langMapp[value]);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', value);

    setState(() {
      _selectedLanguage = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings'), style: TextStyle(color: Colors.white),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 100),
                child: Row(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('language'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(width: 20,),
                    ..._languages.map((item) => 
                    Row(
                      children: <Widget>[
                        Radio(
                          value: item,
                          groupValue: _selectedLanguage,
                          activeColor: kPrimaryColor,
                          onChanged: (value) async {
                            await _changeType(value);
                          },
                        ),
                        Text(item, style: TextStyle(color: Colors.black)),
                      ],
                    )
                    ).toList(),
                  ],
                ),
              ),
            ],
          ),
          
        ),
      ),

      
    );
  }
}
