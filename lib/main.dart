import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:provider/provider.dart';

import './models/patients.dart';

import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (ctx) => Patients(),
        child: MaterialApp(
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          backgroundColor: Colors.white
        ),
        home: AuthScreen(),
      ),
    );
  }
}

