import 'package:flutter/material.dart';
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

class BloodPressure {

  /// Add blood pressure to variable for future use
  /// [arm], [systolic], [diastolic], [pulse] are required as parameters.
  addItem(String arm, int systolic, int diastolic, int pulse, String rightArmReason ) {
    
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

    print(items);

    
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
    _items.add(observation['body']['data']);
    // _items.add(observation['body']['data']);
  }

  /// Prepare blood pressure data
  _prepareBloodPressureData(formData, item) {
    var data = {
      "meta": {
        "device_id": formData['device'],
        'performed_by': formData['performed_by'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
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
    _items.removeAt(index);
  }

  /// Clear all items
  clearItems() {
    _bpItems = [];
    _items = [];
  }
}
