import 'package:intl/intl.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/health_report_repository.dart';

import 'package:uuid/uuid.dart';

class HealthReportController {

  /// Get all the patients
  getReport() async {
    var reports = await HealthReportRepository().getReport();
    return reports;
  }

  getReports() async {
    var reports = await HealthReportRepository().getReports();
    return reports;
  }

  getLastReport(context) async {
    var response = await HealthReportRepository().getLastReport();

    if (response['message'] != null && response['message'] == 'Unauthorized') {
      Helpers().logout(context);
    }
    return response;
  }

  confirmAssessment(reports, comments) async {
    var data = _prepareConfirmData(reports, comments);
    var response = await HealthReportRepository().create(data);

    if (response == null) {
      return 'Server error';
    } else if (response['error'] == true) {
      return 'Error! Data not Saved';
    } else {
      return 'success';
    }
    
  }

  sendForReview(reports, comments) async {
    var data = _prepareReviewData(reports, comments);
    var response = await HealthReportRepository().create(data);

    if (response == null) {
      return 'Server error';
    } else if (response['errors'] != null && response['errors'].isNotEmpty) {
      return 'Error! Data not Saved';
    } else {
      return 'success';
    }
    
  }

  _prepareReviewData(reports, comments) {
    var id = Uuid().v4();
    var patietnId = Patient().getPatient()['uuid'];

    var data = {
      "id": id,
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now()),
        "review_required": true
      },
      "body": {
        "patient_id": patietnId,
        "comment": comments,
        "result": reports
      }
    };

    return data;
  }

  _prepareConfirmData(reports, comments) {
    var id = Uuid().v4();
    var patietnId = Patient().getPatient()['uuid'];

    var data = {
      "id": id,
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "patient_id": patietnId,
        "comment": comments,
        "result": reports
      }
    };

    return data;
  }



}
