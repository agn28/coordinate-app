import 'package:flutter/material.dart';
import '../constants/constants.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({this.text, this.onTap});
  Widget text ;
  Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(4)
        ),
        child: text
      ),
    );
  }
}
