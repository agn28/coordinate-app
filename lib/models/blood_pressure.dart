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
List<BloodPressureItem> _items = [];
List _bpItems = [];

class BloodPressure {

  BloodPressureItem addItem(String arm, double systolic, double diastolic, double pulse ) {
    _items.add(BloodPressureItem(arm, systolic, diastolic, pulse));
    
    return BloodPressureItem(arm, systolic, diastolic, pulse);
  }

  addBloodPressure(formData) {
    
    if (items.isEmpty) {
      return 'Error! No data available!';
    }

    var data;
    _bpItems = [];

    formData['items'].forEach((item) => {
      data = _prepareBloodPressureData(formData, item),
      _bpItems.add(data),
    });

    return 'success';
  }

  _prepareBloodPressureData(formData, item) {
    var data = {
      "meta": {
        "device_id": formData['device'],
        'performed_by': formData['performed_by'],
        "created_at": DateFormat('d MMMM, y').format(DateTime.now())
      },
      "body": {
        "type": "blood_pressure",
        "data": {
          'arm': item.arm,
          'systolic': item.systolic,
          'diastolic': item.diastolic,
          'pulse_rate': item.pulse,
        },
        "comment": formData['comment'],
        'patient_id': Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  List<BloodPressureItem> get items {
    return [..._items];
  }

  List get bpItems {
    return [..._bpItems];
  }

  /// Clear all items
  clearItems() {
    _bpItems = [];
    _items = [];
  }
}
