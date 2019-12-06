import 'package:flutter/material.dart';

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

  List<BloodPressureItem> get items {
    return [..._items];
  }
}