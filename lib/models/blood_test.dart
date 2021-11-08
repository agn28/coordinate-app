import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';

List _items = [];
List _btItems = [];
var bloodTestMap = {
  'tg': 'Triglycerides',
  'total_cholesterol': 'Total Cholesterol',
  'blood_glucose': 'Fasting Blood Glucose',
  'blood_sugar': 'Random Blood Sugar',
  'a1c': 'Hba1c'
};

class BloodTest {

  /// Add blood test item in local variable.
  /// [type], [value], [unit], [comment], [device] are required as parameter.
  addItem(name, value, unit, comment, device) {
    // String convertedType = Helpers().getType(type);
    _items.removeWhere((item) => item['name'] == name);

    if (_items.isNotEmpty && _items[0]['skip'] == true) {
      _items = [];
      _btItems = [];
    }

    if (name == 'blood_glucose') {
      _items.add({
        'name': 'blood_sugar',
        'unit': unit,
        'value': double.parse(value.toString()),
        'comment': comment,
        'device': device,
        'type': 'fasting'
      });
    } else {
      _items.add({
        'name': name,
        'unit': unit,
        'value': double.parse(value.toString()),
        'comment': comment,
        'device': device
      });
    }
    return;
  }

  addSkip(reason) {
    _items = [];
    _btItems = [];
    _items.add({
      'skip': true,
      'reason': reason 
    });

    return 'success';
  }
  
  /// Add observation item.
  addBtItem() {
    if (items.length == 0) {
      return 'Error! Minimum 1 step should be completed.';
    }

    for (var item in _items) {
      bool updated = false;
      for (var bt in _btItems) {
        if (bt['body']['data']['name'] == item['name']) {
          if(item['name'] == 'blood_sugar') {

            if(item['type'] == null && bt['body']['data']['type'] == null) {

              _btItems[_btItems.indexOf(bt)]['body']['data'] = item;
              updated = true;
              break;
            } else if (item['type'] != null && bt['body']['data']['type'] != null
              && bt['body']['data']['type'] == item['type']) {

              _btItems[_btItems.indexOf(bt)]['body']['data'] = item;
              updated = true;
              break;
            } else {

            };
          } else {
            _btItems[_btItems.indexOf(bt)]['body']['data'] = item;
            updated = true;
            break;
          }
        }
      }

      if(!updated) {
        _btItems.add(_prepareData(item));
      }
    }

    return 'success';
  }
  /// Add body measurement item for edit
  /// body measurement [observation] is required as parameter
  addBtItemsForEdit(observation) {
    _btItems.add(observation);
    _items.add(observation['body']['data']);
  }

  /// Prepare observation data.
  _prepareData(item) {
    var data = {
      "meta": {
        "collected_by": Auth().getAuth()['uid'],
        "device_id": item["device"],
        "created_at": DateTime.now().toString()
      },
      "body": {
        "type": "blood_test",
        "data": item,
        "patient_id": Patient().getPatient()['id'],
      }
    };

    return data;
  }

  /// Get all observations added now.
  get items {
    return [..._items];
  }
  
  getMap() {
    return bloodTestMap;
  }

  /// Check observation is added or not.
  bool hasItem(name) {
    return _items.where((item) => item['name'] == Helpers().getType(name)).isNotEmpty;
  }

  getItem(name) {
    var data = _items.where((item) => item['name'] == Helpers().getType(name));

    return data.isNotEmpty ? data.first : {};
  }

  /// Get all Blood Test data.
  List get btItems {
    return [..._btItems];
  }

  /// Clear all items
  clearItems() {
    _btItems = [];
    _items = [];
  }
}
