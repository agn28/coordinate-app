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
        'id': response['data']['id'],
        'data': response['data']['body']
      };
    }
    return 'success';
  }

  setPatientModify(patient) {
    _patient = {
      'id': patient['id'],
      'data': patient['body'],
      'meta': patient['meta']
    };
  }

  getPatient() {
    return _patient;
  }
}
