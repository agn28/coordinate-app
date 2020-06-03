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
