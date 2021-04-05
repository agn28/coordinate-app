import 'package:nhealth/repositories/user_repository.dart';

class UserController {

  getUsers() async {
    var response = await UserRepository().getUsers();

    // await patients.forEach((patient) {
    //   parsedData = jsonDecode(patient['data']);
    //   data.add({
    //     'id': patient['id'],
    //     'data': parsedData['body'],
    //     'meta': parsedData['meta']
    //   });
    // });

    return response;
  }

  getUser(userId) async {
    var response = await UserRepository().getUser(userId);

    return response;
  }

  
}
