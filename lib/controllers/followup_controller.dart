import 'package:nhealth/repositories/followup_repository.dart';


class FollowupController {

  /// Get all the patients
  create(data) async {
    var response = await FollowupRepository().create(data);

    return response;
  }

  update(data) async {
    var response = await FollowupRepository().update(data);

    return response;
  }

  getFollowupsByPatient(patientID) async {
    var response = await FollowupRepository().getFollowupsByPatient(patientID);

    return response;
  }

}
