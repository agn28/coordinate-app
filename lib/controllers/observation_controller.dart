import 'package:nhealth/models/patient.dart';
import 'package:nhealth/repositories/local/concept_manager_repository_local.dart';
import 'package:nhealth/repositories/local/database_creator.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
import 'package:nhealth/repositories/observation_repository.dart';
import 'package:nhealth/models/blood_pressure.dart';
import 'package:nhealth/models/blood_test.dart';
import 'package:nhealth/models/body_measurement.dart';
import 'package:nhealth/models/questionnaire.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

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
      if (obs['body']['patient_id'] == Patient().getPatient()['uuid'] &&
          obs['body']['type'] == 'survey') {
        data.add(obs['body']);
      }
    });
    return data;
  }
}
