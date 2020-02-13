import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';
import 'package:intl/intl.dart';

List _items = [];
List _bmItems = [];

class BodyMeasurement {

  /// Add blood test item in local variable
  /// [type], [value], [unit], [comment], [device] are required as parameter
  addItem(type, value, unit, comment, device) {
    String convertedType = Helpers().getType(type);
    _items.removeWhere((item) => item['type'] == type.toLowerCase());

    _items.add({
      'type': convertedType,
      'unit': unit,
      'value': int.parse(value),
      'comment': comment,
      'device': device
    });

    return 'success';
  }
  
  /// Add Body Measurement item
  addBmItem() {
    if (items.length == 0) {
      return 'Error! Minimum 1 step should be completed';
    }

    for (var item in _items) {
      bool updated = false;
      for (var bt in _bmItems) {
        if (bt['body']['data']['type'] == item['type']) {
          _bmItems[_bmItems.indexOf(bt)]['body']['data'] = item;
          updated = true;
          break;
        }
      }

      if(!updated) {
        _bmItems.add(_prepareData(item));
      }
      
    }
    
    return 'success';
  }

  /// Prepare body measurement data
  _prepareData(item) {
    var data = {
      "meta": {
        "performed_by": "Md. Feroj Bepari",
        "device_id": item['device'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "body_measurement",
        "data": item,
        "patient_id": Patient().getPatient()['uuid'],
        "assessment_id": "264d9d80-1b17-11ea-9ddd-117747515bf8"
      }
    };

    return data;
  }

  /// Add body measurement item for edit
  /// body measurement [observation] is required as parameter
  addBmItemsForEdit(observation) {
    _bmItems.add(observation);
    _items.add(observation['body']['data']);
  }

  /// Get all observations added now.
  get items {
    return [..._items];
  }

  /// Check observation is added or not
  bool hasItem (type) {
    return _items.where((item) => item['type'] == type.toLowerCase()).isNotEmpty;
  }

  /// Get all Blood Test data.
  List get bmItems {
    return [..._bmItems];
  }

  /// Clear all items
  clearItems() {
    _bmItems = [];
    _items = [];
  }
}
