import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/observation_repository.dart';

var bloodPressures = [];

class ObservationController {

  /// Get all the assessments.
  getLiveSurveysByPatient() async {
    var observations = await ObservationRepository().getObservations();
    var data = [];
    if (observations == null) {
      return data;
    }
    await observations['data'].forEach((obs) {
      if (obs['body']['patient_id'] == Patient().getPatient()['uuid'] && obs['body']['type'] == 'survey') {
        data.add(obs['body']);
      }
    });
    return data;
  }

 
}
