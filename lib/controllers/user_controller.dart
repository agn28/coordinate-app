import 'package:intl/intl.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'dart:convert';

import 'package:nhealth/repositories/patient_repository.dart';
import 'package:nhealth/repositories/user_repository.dart';

class UserController {

  getUsers() async {
    var response = await UserRepository().getUsers();

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'uuid': patient['uuid'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    return response;
  }

  
}
