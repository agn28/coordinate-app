import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'package:nhealth/repositories/worklist_repository.dart';

var bloodPressures = [];

class WorklistController {

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  getWorklist() async {

    var response = await WorklistRepository().getWorklist();

    return response;
  }

  getPatientsWorklist() async {

    var response = await WorklistRepository().getWorklist();

    return response;
  }

  update(type, comment) {
    var data = _prepareUpdateData(type, comment);
    var status = AssessmentRepositoryLocal().update(data);
    if (status == 'success') {
      Helpers().clearObservationItems();
    }

    return status;
  }

  /// Prepare data to create an assessment.
  /// Assessment [type] and [comment] is required as parameter.
  _prepareUpdateData(type, comment) {
    var data = {
      "meta": Assessment().getSelectedAssessment()['meta'],
      "body": {
        "type": type == 'In-clinic Screening' ? 'in-clinic' : 'visit',
        "comment": comment,
        "performed_by": Assessment().getSelectedAssessment()['data']['performed_by'],
        "assessment_date": Assessment().getSelectedAssessment()['data']['assessment_date'],
        "patient_id": Assessment().getSelectedAssessment()['data']['patient_id']
      }
    };

    return data;
  }

  /// Prepare data to create an assessment.
  /// Assessment [type] and [comment] is required as parameter.
  // _prepareData(type, comment) {
  //   var data = {
  //     "meta": {
  //       "collected_by": Auth().getAuth()['uid'],
  //       "start_time": "17 December, 2019 12:00",
  //       "end_time": "17 December, 2019 12:05",
  //       "created_at": DateTime.now().toString()
  //     },
  //     "body": {
  //       "type": type == 'In-clinic Screening' ? 'in-clinic' : 'visit',
  //       "comment": comment,
  //       "performed_by": Auth().getAuth()['uid'],
  //       "assessment_date": DateFormat('y-MM-dd').format(DateTime.now()),
  //       "patient_id": Patient().getPatient()['uuid']
  //     }
  //   };

  //   return data;
  // }

  edit(assessment, observations) {
    Assessment().selectAssessment(assessment);
    Helpers().clearObservationItems();
    observations.forEach((item) {
      if (item['body']['type'] == 'body_measurement') {
        BodyMeasurement().addBmItemsForEdit(item);
      } else if (item['body']['type'] == 'blood_test') {
        BloodTest().addBtItemsForEdit(item);
      } else if (item['body']['type'] == 'blood_pressure') {
        BloodPressure().addBpItemsForEdit(item);
      } else if (item['body']['type'] == 'survey') {
        Questionnaire().addQnItemsForEdit(item);
        // BloodPressure().addBpItemsForEdit(item);
      }
    });
  }
  
}
