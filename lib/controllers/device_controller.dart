import 'package:nhealth/repositories/device_repository.dart';

class DeviceController {

  getDevices() async {
    var response = await DeviceRepository().getDevices();

    if (!response['error']) {
      return response['data'];
    }
    return response['message'];
  }

  
}
