import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/actions_swipper_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/improve_bp_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/other_actions_screen.dart';
import 'package:nhealth/screens/chw/chw_home_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/counselling_framwork_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/couselling_confirmation_screen.dart';
import 'package:nhealth/screens/chw/encounters/new_chw_encounter_screen.dart';
import 'package:nhealth/screens/chw/new_community_visit/patient_feeling_screen.dart';
import 'package:nhealth/screens/chw/new_community_visit/verify_patient_screen.dart';
import 'package:nhealth/screens/chw/new_patient_questionnairs/new_patient_questionnaire_screen.dart';
import 'package:nhealth/screens/chw/new_patient_questionnairs/new_questionnaire_acute_screen.dart';
import 'package:nhealth/screens/chw/new_patient_questionnairs/new_questionnaire_feeling_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_details_screen.dart';
import 'package:nhealth/screens/chw/patients/patient_summary_screen.dart';
import 'package:nhealth/screens/chw/patients/report_medical_issues_screen.dart';
import 'package:nhealth/screens/chw/referrals/referral_list_screen.dart';
import 'package:nhealth/screens/chw/referrals/referral_patients_screen.dart';
import 'package:nhealth/screens/chw/unwell/continue_screen.dart';
import 'package:nhealth/screens/chw/unwell/followup_screen.dart';
import 'package:nhealth/screens/chw/unwell/medical_recomendation_screen.dart';
import 'package:nhealth/screens/chw/unwell/create_referral_screen.dart';
import 'package:nhealth/screens/chw/unwell/severity_screen.dart';
import 'package:nhealth/screens/chw/unwell/update_referral_screen.dart';
import 'package:nhealth/screens/chw/work-list/chw_navigation_screen.dart';
import 'package:nhealth/screens/home_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_details_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/encounter_details_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_overview_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_overview_screen_old.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';

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
      case '/patientOverviewOld':
        return CupertinoPageRoute(builder: (_) => PatientRecordsScreenOld());
        
      case '/carePlanDetails':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => CarePlanDetailsScreen( carePlans: data));
      case '/carePlanInterventions':
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => CarePlanInterventionScreen( carePlan: data['carePlan'], parent: data['parent']));
      case '/encounterDetails':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => EncounterDetailsScreen( encounter: data ));

      case '/chwHome':
        return CupertinoPageRoute(builder: (_) => ChwHomeScreen());

      case '/chwPatientSummary':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => ChwPatientRecordsScreen(checkInState: data));

      case '/chwNavigation':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => ChwNavigationScreen(pageIndex: data,));
      case '/verifyPatient':
        return CupertinoPageRoute(builder: (_) => VerifyPatientScreen());
      case '/patientFeeling':
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => PatientFeelingScreen(communityClinic: data != null ? data['communityClinic'] : null));
      case '/chwFollowup':
        return CupertinoPageRoute(builder: (_) => ChwFollowupScreen());
      case '/chwSeverity':
        return CupertinoPageRoute(builder: (_) => SeverityScreen());
      case '/chwContinue':
        return CupertinoPageRoute(builder: (_) => ContinueScreen());
      case '/chwImproveBp':
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => ImproveBpControlScreen(data: data['data'], parent: data['parent'],));
      case '/reportMedicalIssues':
        return CupertinoPageRoute(builder: (_) => ReportMedicalIssuesScreen());
      case CounsellingFrameworkScreen.path:
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => CounsellingFrameworkScreen(data: data['data'], parent: data['parent']));
      case CounsellingConfirmation.path:
      var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => CounsellingConfirmation(data: data['data']));

      case MedicalRecommendationScreen.path:
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => MedicalRecommendationScreen(referralData: data,));
      case CreateReferralScreen.path:
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => CreateReferralScreen(referralData: data,));

      case '/updateReferral':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => UpdateReferralScreen(referral: data,));
      case '/referralList':
        return CupertinoPageRoute(builder: (_) => ChwReferralListScreen());

      case '/chwOtherActions':
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => OtherActionsScreen(data: data['data'], parent: data['parent'],));

      case '/chwActionsSwipper':
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => ActionsSwipperScreen(carePlan: data['data'], parent: data['parent'],));
      
      case '/chwPatientDetails':
        return CupertinoPageRoute(builder: (_) => PatientDetailsScreen());
      
      case '/chwNewEncounter':
        var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => NewChwEncounterScreen(communityClinic: data != null ? data['communityClinic'] : null));
      case '/chwReferralPatients':
        return CupertinoPageRoute(builder: (_) => ChwReferralPatientsScreen());
      
      case NewPatientQuestionnaireScreen.path:
        return CupertinoPageRoute(builder: (_) => NewPatientQuestionnaireScreen());
      case NewQuestionnaireFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => NewQuestionnaireFeelingScreen());
      case NewQuestionnaireAcuteScreen.path:
        return CupertinoPageRoute(builder: (_) => NewQuestionnaireAcuteScreen());
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
