import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/assessment.dart';
import 'package:nhealth/repositories/local/assessment_repository_local.dart';
import 'package:nhealth/repositories/medical_issues_repository.dart';

var bloodPressures = [];

class MedicalIssuesController {

  /// Create assessment.
  /// Assessment [type] and [comment] is required as parameter.
  getIssues() async {

    var response = await MedicalIssuesRepository().getIssues();

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

  
}
