import 'package:flutter/material.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:intl/intl.dart';

class BloodPressureItem with ChangeNotifier {
  final String arm;
  final double  systolic;
  final double diastolic;
  final double pulse;

  BloodPressureItem(
    this.arm,
    this.systolic,
    this.diastolic,
    this.pulse
  );
}
List _items = [];
List _bpItems = [];
List _bpDeleteIds = [];

class BloodPressure {

  /// Add blood pressure to variable for future use
  /// [arm], [systolic], [diastolic], [pulse] are required as parameters.
  addItem(String arm, int systolic, int diastolic, int pulse, String rightArmReason ) {
    if (_items.isNotEmpty && _items[0]['skip'] == true) {
      _items = [];
    }
    
    if (arm == 'right') {
      _items.add({
        'arm': arm,
        'systolic': systolic,
        'diastolic': diastolic,
        'pulse_rate': pulse,
        'reason': rightArmReason
      });
    } else {
      _items.add({
        'arm': arm,
        'systolic': systolic,
        'diastolic': diastolic,
        'pulse_rate': pulse,
      });
    }

    return 'success';
  }

  addSkip(reason) {
    _items = [];
    _bpItems = [];
    _items.add({
      'skip': true,
      'reason': reason
    });
    return 'success';
  }

  /// Add blood pressures as observation
  addBloodPressure(formData) {
    
    if (items.isEmpty) {
      return 'Error! No data available!';
    }

    var data;
    _bpItems = [];

    formData['items'].forEach((item) {
      data = _prepareBloodPressureData(formData, item);
      _bpItems.add(data);
    });

    return 'success';
  }

  /// Add body measurement item for edit
  /// body measurement [observation] is required as parameter
  addBpItemsForEdit(observation) {
    _bpItems.add(observation);
    Map<String, dynamic> data = {
      'id': observation['uuid']
    };
    data.addAll(observation['body']['data']);
    _items.add(data);
    // _items.add(observation['body']['data']);
  }

  /// Prepare blood pressure data
  _prepareBloodPressureData(formData, item) {
    var data = {
      "meta": {
        "device_id": formData['device'],
        "collected_by": Auth().getAuth()['uid'],
        "created_at": DateTime.now().toString()
      },
      "body": {
        "type": "blood_pressure",
        "data": item,
        "comment": formData['comment'],
        'patient_id': Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Get all blood pressure items
  List get items {
    return [..._items];
  }

  /// Get all blood pressure items as observations
  List get bpItems {
    return [..._bpItems];
  }

  /// Remove an item by index
  removeItem(index) {
    _bpDeleteIds.add(_items[index]['id']);
    _items.removeAt(index);
  }

  get deleteIds {
    return _bpDeleteIds;
  }

  removeDeleteIds() {
    _bpDeleteIds = [];
  }

  /// Clear all items
  clearItems() {
    _bpItems = [];
    _items = [];
  }
}
