import 'package:flutter/material.dart';
import 'package:nhealth/models/patient.dart';

// import './blood_pressure_item.dart';

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
double test = 1;
List<BloodPressureItem> _items = [];
List _bpItems = [];

class BloodPressure {
  // List<BloodPressureItem> _items = [];
  // double test = 1;

  BloodPressureItem addItem(String arm, double systolic, double diastolic, double pulse ) {

    // print(systolic);
    _items.add(BloodPressureItem(arm, systolic, diastolic, pulse));
    
    test = test + systolic;
    print(_items.length);
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
      //print(_bpItems),
    });

    return 'success';

  }

  _prepareBloodPressureData(formData, item) {
    var data = {
      "meta": {
        "collected_by": "8vLsBJkEOGOQyyLXQ2vZzycmqQX2",
        "start_time": "17 December, 2019 12:00",
        "end_time": "17 December, 2019 12:05"
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
        'performed_by': formData['performed_by']
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
}