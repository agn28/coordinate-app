import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';

List _items = [];
List _btItems = [];

class BloodTest {

  /// Add blood test item in local variable.
  /// [type], [value], [unit], [comment], [device] are required as parameter.
  addItem(type, value, unit, comment, device) {
    String convertedType = Helpers().getType(type);
    _items.removeWhere((item) => item['type'] == convertedType);

    _items.add({
      'type': convertedType,
      'unit': unit,
      'value': value,
      'comment': comment,
      'device': device
    });

    return;
  }
  
  /// Add observation item.
  addBtItem() {
    if (items.length < 3) {
      return 'Error! All steps are not completed.';
    }
    _btItems = [];
    _items.forEach((item) => {
      _btItems.add(_prepareData(item))
    });
    return 'success';
  }

  /// Prepare observation data.
  _prepareData(item) {
    var data = {
      "meta": {
        "performed_by": "8vLsBJkEOGOQyyLXQ2vZzycmqQX2",
        "device_id": "DV-1234"
      },
      "body": {
        "type": "blood_test",
        "data": item,
        "patient_id": Patient().getPatient()['uuid'],
        "assessment_id": "264d9d80-1b17-11ea-9ddd-117747515bf8"
      }
    };

    return data;
  }

  /// Get all observations added now.
  get items {
    return [..._items];
  }

  /// Check observation is added or not.
  bool hasItem (type) {
    return _items.where((item) => item['type'] == Helpers().getType(type)).isNotEmpty;
  }

  /// Get all Blood Test data.
  List get btItems {
    return [..._btItems];
  }
}
