import 'package:nhealth/models/auth.dart';
import 'package:nhealth/repositories/auth_repository.dart';

class AuthController {

  /// Get all the patients
  login(email, password) async {
    var response = await AuthRepository().login(email, password);

    if (response['uid'] != null) {
      Auth().setAuth(response);
      return response;
    }

    return 'error';
  }

}
