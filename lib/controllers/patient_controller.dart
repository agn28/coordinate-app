import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/repositories/local/patient_repository_local.dart';
import 'dart:convert';

class PatientController {

  getAllPatients() async {
    var patients = await PatientReposioryLocal().getAllPatients();
    var data = [];
    var parsedData;

    await patients.forEach((patient) => {
      parsedData = jsonDecode(patient['data']),
      data.add({
        'uuid': patient['uuid'],
        'data': parsedData['body'],
        'meta': parsedData['meta']
      }),
    });

    return data;
  }

  create(formData) async {
    final data = _prepareData(formData);
    await PatientReposioryLocal().create(data);

    return 'success';
  }

  _prepareData(formData) {
    final age = Helpers().calculateAge(formData['birth_year'], formData['birth_month'], formData['birth_date']);
    String birthDate = formData['birth_year'] + '-' + formData['birth_month'] + '-' + formData['birth_date'];
    formData.remove('birth_date');
    formData.remove('birth_month');
    formData.remove('birth_year');
    formData['age'] = age;
    formData['birth_date'] = birthDate;
    
    var data = {
      "meta": {
        "performed_by": "9b900fa6-209e-11ea-978f-2e728ce88125",
      },
      "body": formData
    };
    return data;
  }

}
