import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/screens/chcp/patient_list_chcp_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/actions_swipper_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/careplan_delivery_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/improve_bp_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/other_actions_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/unwell_careplan_screen.dart';
import 'package:nhealth/screens/chw/chw_home_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/counselling_framwork_screen.dart';
import 'package:nhealth/screens/chw/counselling_framework/couselling_confirmation_screen.dart';
import 'package:nhealth/screens/chw/encounters/new_chw_encounter_screen.dart';
import 'package:nhealth/screens/chw/careplan_actions/careplan_feeling_screen.dart';
import 'package:nhealth/screens/chw/followup/well_followup_screen.dart';
import 'package:nhealth/screens/chw/new_community_visit/patient_feeling_screen.dart';
import 'package:nhealth/screens/chw/new_community_visit/verify_patient_screen.dart';
import 'package:nhealth/screens/chw/new_patient_questionnairs/edit_incomplete_encounter_chw_screen.dart';
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
import 'package:nhealth/screens/nurse/new_patient_questionnairs/followup/full_assessment_screen.dart';
import 'package:nhealth/screens/nurse/new_patient_questionnairs/new_patient_questionnaire_screen.dart';
import 'package:nhealth/screens/nurse/new_patient_questionnairs/new_questionnaire_acute_screen.dart';
import 'package:nhealth/screens/nurse/new_patient_questionnairs/new_questionnaire_feeling_screen.dart';
import 'package:nhealth/screens/patients/edit_patient_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_details_screen.dart';
import 'package:nhealth/screens/patients/manage/care_plan/care_plan_intervention_screen.dart';
import 'package:nhealth/screens/patients/manage/encounters/encounter_details_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_overview_screen.dart';
import 'package:nhealth/screens/patients/manage/patient_overview_screen_old.dart';
import 'package:nhealth/screens/patients/manage/patient_search_screen.dart';
import 'package:nhealth/screens/patients/ncd/edit_incomplete_encounter_screen.dart';
import 'package:nhealth/screens/patients/ncd/edit_incomplete_full_followup_screen.dart';
import 'package:nhealth/screens/patients/ncd/edit_incomplete_short_followup_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_acute_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_feeling_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_patient_summary_screen.dart';
import 'package:nhealth/screens/patients/ncd/followup_visit_screen.dart';
import 'package:nhealth/screens/patients/ncd/ncd_patient_summary_screen.dart';
import 'package:nhealth/screens/patients/ncd/new_followup_screen.dart';
import 'package:nhealth/screens/patients/ncd/search/first_center_search_screen.dart';
import 'package:nhealth/screens/patients/ncd/search/followup_search_screen.dart';
import 'package:nhealth/screens/patients/ncd/search/unwell_followup_screen.dart';
import 'package:nhealth/screens/patients/patient_update_summary_screen.dart';
import 'package:nhealth/screens/chw/unwell/followup_screen.dart';
import 'package:nhealth/screens/patients/register_patient_success_screen.dart';

import 'screens/chcp/chcp_careplan_delivery_screen.dart';
import 'screens/chcp/chcp_careplan_feeling_screen.dart';
import 'screens/chcp/chcp_counselling_confirmation_screen.dart';
import 'screens/chcp/chcp_feeling_screen.dart';
import 'screens/chcp/chcp_full_assessment_feeling_screen.dart';
import 'screens/chcp/chcp_home_screen.dart';
import 'screens/chcp/chcp_navigation_screen.dart';
import 'screens/chcp/chcp_patient_summary_screen.dart';
import 'screens/chcp/chcp_short_followup_feeling_screen.dart';
import 'screens/chcp/chcp_unwell_careplan_screen.dart';
import 'screens/chcp/chcp_work_list_summary_screen.dart';
import 'screens/chcp/edit_incomplete_encounter_chcp_screen.dart';
import 'screens/chcp/edit_incomplete_full_followup_chcp_screen.dart';
import 'screens/chcp/edit_incomplete_short_followup_chcp_screen.dart';
import 'screens/chcp/followup_patient_chcp_summary_screen.dart';
import 'screens/chcp/short_followup_chcp_screen.dart';
import 'screens/chcp/full_assessment_chcp_screen.dart';
import 'screens/chcp/new_followup_chcp_screen.dart';
import 'screens/chcp/new_visit/new_patient_questionnaire_chcp_screen.dart';
import 'screens/chcp/new_visit/new_visit_chcp_feeling_screen.dart';
import 'screens/chcp/new_visit/new_visit_unwell_chcp_screen.dart';
import 'screens/chcp/unwell_chcp_screen.dart';
import 'screens/chcp/unwell_full_assessment_chcp_screen.dart';
import 'screens/chcp/unwell_short_followup_chcp_screen.dart';
import 'screens/chw/followup/edit_followup_screen.dart';


class RouteGenerator {
  static Route<dynamic>  generarteRoute(RouteSettings settings) {
    
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (ctx) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => AuthScreen());
      case '/patientSearch':
        return CupertinoPageRoute(builder: (_) => PatientSearchScreen());
      case '/firstCenterSearch':
        return CupertinoPageRoute(builder: (_) => FirstCenterSearchScreen());
      case FollowupSearchScreen.path:
        return CupertinoPageRoute(builder: (_) => FollowupSearchScreen());
      case '/patientOverview':
      var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => PatientRecordsScreen(prevScreen: data['prevScreen']));
      case '/ncdPatientSummary':
        return CupertinoPageRoute(builder: (_) => NcdPatientSummaryScreen());
      case FollowupPatientSummaryScreen.path:
      var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => FollowupPatientSummaryScreen( prevScreen: data['prevScreen'], encounterData: data['encounterData']));
      case FollowupFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => FollowupFeelingScreen());
      case FollowupVisitScreen.path:
        return CupertinoPageRoute(builder: (_) => FollowupVisitScreen());
      case WellFollowupScreen.path:
        return CupertinoPageRoute(builder: (_) => WellFollowupScreen());
      case FullAssessmentScreen.path:
        return CupertinoPageRoute(builder: (_) => FullAssessmentScreen());
      case FollowupAcuteScreen.path:
        return CupertinoPageRoute(builder: (_) => FollowupAcuteScreen());
      case ChwFollowupScreen.path:
        return CupertinoPageRoute(builder: (_) => ChwFollowupScreen());
      case UnwellFollowupScreen.path:
      return CupertinoPageRoute(builder: (_) => UnwellFollowupScreen());
      case '/patientOverviewOld':
        return CupertinoPageRoute(builder: (_) => PatientRecordsScreenOld());

      case '/editIncompleteEncounter':
        return CupertinoPageRoute(builder: (_) => EditIncompleteEncounterScreen());
      case '/editIncompleteShortFollowup':
        return CupertinoPageRoute(builder: (_) => EditIncompleteShortFollowupScreen());
      case '/editIncompleteFullFollowup':
        return CupertinoPageRoute(builder: (_) => EditIncompleteFullFollowupScreen());
      case '/editFollowup':
        return CupertinoPageRoute(builder: (_) => EditFollowupScreen());


      case ChwCareplanDeliveryScreen.path:
        return CupertinoPageRoute(builder: (_) => ChwCareplanDeliveryScreen());
      case CareplanFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => CareplanFeelingScreen());
      case UnwellCareplanScreen.path:
        return CupertinoPageRoute(builder: (_) => UnwellCareplanScreen());
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
      var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => ChwPatientRecordsScreen(prevScreen: data['prevScreen'], encounterData: data['encounterData']));
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
        return CupertinoPageRoute(builder: (_) => CounsellingConfirmation(data: data['data'], parent: data['parent']));

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
      case EditIncompleteEncounterChwScreen.path:
        return CupertinoPageRoute(builder: (_) => EditIncompleteEncounterChwScreen());
      case NewQuestionnaireFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => NewQuestionnaireFeelingScreen());
      case NewQuestionnaireAcuteScreen.path:
        return CupertinoPageRoute(builder: (_) => NewQuestionnaireAcuteScreen());

      case NewPatientQuestionnaireNurseScreen.path:
        return CupertinoPageRoute(builder: (_) => NewPatientQuestionnaireNurseScreen());
      case NewQuestionnaireFeelingNurseScreen.path:
        return CupertinoPageRoute(builder: (_) => NewQuestionnaireFeelingNurseScreen());
      case NewQuestionnaireAcuteNurseScreen.path:
        return CupertinoPageRoute(builder: (_) => NewQuestionnaireAcuteNurseScreen());

      case PatientUpdateSummary.path:
        return CupertinoPageRoute(builder: (_) => PatientUpdateSummary());
      case EditPatientScreen.path:
        return CupertinoPageRoute(builder: (_) => EditPatientScreen());
      case NewFollowupScreen.path:
        return CupertinoPageRoute(builder: (_) => NewFollowupScreen());
      case RegisterPatientSuccessScreen.path:
        return CupertinoPageRoute(builder: (_) => RegisterPatientSuccessScreen());

      // chcp routes
      case '/chcpHome':
        return CupertinoPageRoute(builder: (_) => ChcpHomeScreen());
      case '/patientListChcp':
        return CupertinoPageRoute(builder: (_) => PatientListChcpScreen());
      case '/chcpPatientSummary':
        return CupertinoPageRoute(builder: (_) => ChcpPatientSummaryScreen());
      case ChcpFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => ChcpFeelingScreen());
      case '/editIncompleteEncounterChcp':
        return CupertinoPageRoute(builder: (_) => EditIncompleteEncounterChcpScreen());
      case UnwellChcpScreen.path:
      return CupertinoPageRoute(builder: (_) => UnwellChcpScreen());
      case NewFollowupChcpScreen.path:
        return CupertinoPageRoute(builder: (_) => NewFollowupChcpScreen());
      case FullAssessmentChcpScreen.path:
        return CupertinoPageRoute(builder: (_) => FullAssessmentChcpScreen());
      case ChcpFullAssessmentFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => ChcpFullAssessmentFeelingScreen());
      case UnwellFullAssessmentChcpScreen.path:
        return CupertinoPageRoute(builder: (_) => UnwellFullAssessmentChcpScreen());
      case FollowupVisitChcpScreen.path:
        return CupertinoPageRoute(builder: (_) => FollowupVisitChcpScreen());
      case ChcpShortFollowupFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => ChcpShortFollowupFeelingScreen());
      case UnwellShortFollowupChcpScreen.path:
        return CupertinoPageRoute(builder: (_) => UnwellShortFollowupChcpScreen());
      case '/chcpNavigation':
        var data = settings.arguments;
        return CupertinoPageRoute(builder: (_) => ChcpNavigationScreen(pageIndex: data,));
      case FollowupPatientChcpSummaryScreen.path:
      var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => FollowupPatientChcpSummaryScreen( prevScreen: data['prevScreen'], encounterData: data['encounterData']));
      case '/editIncompleteFullFollowupChcp':
        return CupertinoPageRoute(builder: (_) => EditIncompleteFullFollowupChcpScreen());
      case '/editIncompleteShortFollowupChcp':
        return CupertinoPageRoute(builder: (_) => EditIncompleteShortFollowupChcpScreen());
      case '/chcpWorkListSummary':
      var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => ChcpWorkListSummaryScreen(prevScreen: data['prevScreen'], encounterData: data['encounterData']));
      case ChcpCareplanFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => ChcpCareplanFeelingScreen());
      case ChcpCareplanDeliveryScreen.path:
        return CupertinoPageRoute(builder: (_) => ChcpCareplanDeliveryScreen());
      case ChcpUnwellCareplanScreen.path:
        return CupertinoPageRoute(builder: (_) => ChcpUnwellCareplanScreen());
      case ChcpCounsellingConfirmation.path:
      var data = settings.arguments as Map;
        return CupertinoPageRoute(builder: (_) => ChcpCounsellingConfirmation(data: data['data'], parent: data['parent']));
      // chcp new visit 
      case NewPatientQuestionnaireChcpScreen.path:
        return CupertinoPageRoute(builder: (_) => NewPatientQuestionnaireChcpScreen());
      case NewVisitChcpFeelingScreen.path:
        return CupertinoPageRoute(builder: (_) => NewVisitChcpFeelingScreen());
      case NewVisitUnwellChcpScreen.path:
      return CupertinoPageRoute(builder: (_) => NewVisitUnwellChcpScreen());

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
