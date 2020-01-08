import 'package:flutter/material.dart';
import 'package:nhealth/constants/constants.dart';
import './repositories/local/database_creator.dart';
import 'package:provider/provider.dart';

import './models/patients.dart';

import './screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
}

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

