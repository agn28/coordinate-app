import 'package:nhealth/controllers/patient_controller.dart';

var _patient;

class Patient {
  setPatient(patient) {
    _patient = patient;
  }
  setPatientById(patientId) async {
    var response = await PatientController().getPatient(patientId);
    print('response');
    print(response);
    if (response['error'] != null && response['error'] == false) {
      _patient = {
        'uuid': response['data']['id'],
        'data': response['data']['body']
      };
    }
    print(_patient);
    return 'success';
  }

  getPatient() {
    return _patient;
  }
}
