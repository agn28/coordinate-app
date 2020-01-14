import 'package:flutter/material.dart';
import 'package:nhealth/models/patient.dart';

List _items = [];
List _btItems = [];

class BloodTest {
  // List<BloodPressureItem> _items = [];
  // double test = 1;

  addItem(type, value, unit, comment, device) {

    String convertedType = _getType(type);
    _items.removeWhere((item) => item['type'] == convertedType);

    _items.add({
      'type': convertedType,
      'unit': unit,
      'value': value,
      'comment': comment,
      'device': device
    });
    
    print(_items);

    return;
  }

  _getType(type) {
    return type.toLowerCase().replaceAll(' ', '_');
  }
    // _items.update();
    // return;
  
  addBtItem() {
    if (items.length < 3) {
      return 'Error! All steps are not completed.';
    }
    _btItems = [];
    _items.forEach((item) => {
      _btItems.add(_prepareData(item))
    });
    print(_btItems);
    return 'success';
  }

  _prepareData(item) {
    var data = {
      "meta": {
        "performed_by": "8vLsBJkEOGOQyyLXQ2vZzycmqQX2",
        "device_id": "DV-1234"
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

  get items {
    return [..._items];
  }

  bool hasItem (type) {
    return _items.where((item) => item['type'] == _getType(type)).isNotEmpty;
  }

  List get btItems {
    return [..._btItems];
  }
}