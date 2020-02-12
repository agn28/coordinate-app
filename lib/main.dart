import 'package:flutter/material.dart';
import 'package:nhealth/concept-manager/concept_manager.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/observation_concepts.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
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
      home: AuthScreen(),
    );
  }
}

