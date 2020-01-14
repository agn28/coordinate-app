import 'package:flutter/material.dart';
import 'package:nhealth/models/patient.dart';

List _items = [];
List _bmItems = [];

class BodyMeasurement {
  // List<BloodPressureItem> _items = [];
  // double test = 1;

  addItem(type, value, unit, comment, device) {

    print(_items);
    _items.removeWhere((item) => item['type'] == type.toLowerCase());

    _items.add({
      'type': type.toLowerCase(),
      'unit': unit,
      'value': value,
      'comment': comment,
      'device': device
    });

    return;
  }
    // _items.update();
    // return;
  
  addBmItem() {
    if (items.length < 3) {
      return 'Error! All steps are not completed.';
    }
    _bmItems = [];
    _items.forEach((item) => {
      _bmItems.add(_prepareData(item))
    });
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
    return _items.where((item) => item['type'] == type.toLowerCase()).isNotEmpty;
  }

  List get bmItems {
    return [..._bmItems];
  }
}