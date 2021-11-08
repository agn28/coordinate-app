import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nhealth/helpers/functions.dart';
import 'package:nhealth/repositories/followup_repository.dart';
import 'package:nhealth/repositories/local/referral_repository_local.dart';
import 'package:nhealth/repositories/referral_repository.dart';


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
    var response;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      var apiResponse = await FollowupRepository().getFollowupsByPatient(patientID);

      return apiResponse;
    
    } else {
      response = await ReferralRepositoryLocal().getReferralsByPatient(patientID);

      var data;

      if (isNotNull(response)) {
        data = {
          'data': []
        };

        response.forEach((referral) {
          var parsedData = json.decode(referral['data']);

          data['data'].add({
            'id': referral['id'],
            'body': parsedData['body'],
            'meta': parsedData['meta']
          });
        });

        return data;
        
      }
    }

    return response;
  }

}
