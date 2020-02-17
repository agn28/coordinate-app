import 'package:flutter/material.dart';
import 'package:nhealth/concept-manager/concept_manager.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/observation_concepts.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
import 'package:nhealth/screens/home_screen.dart';
import './repositories/local/database_creator.dart';
import './screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
  
  if (DatabaseCreator().dBCreatedStatus()) {
    await ObservationConcepts().getItems().forEach((item) {
      ObservationConceptsRepositoryLocal().create(item);
    });
    await ConceptManager().sync();
    DatabaseCreator().dBCreatedStatusChange(false);
  }
  
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        backgroundColor: Colors.white
      ),
      home: CheckAuth(),
    );
  }
}

class CheckAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Auth().getStorageAuth().then((success) {
      if (success['status']) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
      }
    });

    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

