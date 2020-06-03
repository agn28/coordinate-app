import 'package:nhealth/repositories/followup_repository.dart';


class FollowupController {

  /// Get all the patients
  create(data) async {
    var response = await FollowupRepository().create(data);

    return response;
  }

}
