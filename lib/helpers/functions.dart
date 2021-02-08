import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhealth/constants/constants.dart';

isNotNull(data)  {
  return data != null;
}
isNull(data)  {
  return data == null;
}
showErrorSnackBar(title, message) {
  Get.snackbar(title, message, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15), margin: EdgeInsets.all(0), borderRadius: 2);
}
showWarningSnackBar(title, message) {
  Get.snackbar(title, message, backgroundColor: kPrimaryYellowColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15), margin: EdgeInsets.all(0), borderRadius: 2);
}