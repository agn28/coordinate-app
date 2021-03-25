import 'package:nhealth/controllers/patient_controller.dart';

var _patient;

class Patient {
  setPatient(patient) {
    _patient = patient;
  }
  setPatientById(patientId) async {
    var response = await PatientController().getPatient(patientId);
    if (response['error'] != null && response['error'] == false) {
      _patient = {
        'uuid': response['data']['id'],
        'data': response['data']['body']
      };
    }
    return 'success';
  }

  setPatientModify(patient) {
    _patient = {
      'uuid': patient['id'],
      'data': patient['body'],
      'meta': patient['meta']
    };
  }

  setPatientReviewRequiredTrue() {
    _patient['meta']['review_required'] = true;
  }

  getPatient() {
    return _patient;
  }
}
