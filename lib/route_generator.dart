import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nhealth/main.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/new_communiti_visit/patient_feeling_screen.dart';
import 'package:nhealth/screens/chw/new_communiti_visit/verify_patient_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';
import 'package:nhealth/screens/chw/work-list/chw_home_screen.dart';
import 'package:nhealth/screens/chw/work-list/work_list_search_screen.dart';
import 'package:nhealth/screens/home_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_details_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/encounter_details_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_overview_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_overview_screen_old.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';

class RouteGenerator {
  static Route<dynamic>  generarteRoute(RouteSettings settings) {
    
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (ctx) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => AuthScreen());
      case '/patientSearch':
        return CupertinoPageRoute(builder: (_) => PatientSearchScreen());
      case '/patientOverview':
        return CupertinoPageRoute(builder: (_) => PatientRecordsScreen());
      case '/carePlanDetails':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => CarePlanDetailsScreen( carePlans: data));
      case '/carePlanInterventions':
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => CarePlanInterventionScreen( carePlan: data['carePlan'], parent: data['parent']));
      case '/encounterDetails':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => EncounterDetailsScreen( encounter: data ));

      case '/chwPatientSummary':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => ChwPatientRecordsScreen(checkInState: data));

      case '/chwHome':
        return CupertinoPageRoute(builder: (_) => ChwHomeScreen());
      case '/verifyPatient':
        return CupertinoPageRoute(builder: (_) => VerifyPatientScreen());
      case '/patientFeeling':
        return CupertinoPageRoute(builder: (_) => PatientFeelingScreen());
    }
  }
}

// goTo(isAuth, Widget screen) async {
//   if (isAuth) {
//     print('isauth');
//     Auth().getStorageAuth().then((success) {
//       if (success['status']) {
//         return MaterialPageRoute(builder: (ctx) => screen);
//       } else {
//         return MaterialPageRoute(builder: (ctx) => AuthScreen());
//       }
//     });

//     // if (Auth().isExpired()) {
//     //   print('auth expired');
//     //   return MaterialPageRoute(builder: (_) => AuthScreen());
//     // }
//     // print('not expired');
//     // return MaterialPageRoute(builder: (_) => screen);
//   }
//   print('no auth');
//   return MaterialPageRoute(builder: (_) => screen);
// }
