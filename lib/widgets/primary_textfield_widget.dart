import 'package:flutter/material.dart';
import '../constants/constants.dart';

class PrimaryTextField extends StatelessWidget {
  PrimaryTextField({this.prefixIcon, this.suffixIcon, this.hintText, this.topPaadding, this.bottomPadding, this.controller, this.name});

  final Icon prefixIcon;
  final Icon suffixIcon;
  final String hintText;
  final double topPaadding;
  final double bottomPadding;
  final TextEditingController controller;
  final String name;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
      controller: controller,
      validator: (value) {
        if (value.isEmpty) {
          String field = name != null ? name : 'This field';
          return '$field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: topPaadding != null ? topPaadding : 25.0, bottom: bottomPadding != null ? bottomPadding : 25.0, left: 10, right: 10),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: kSecondaryTextField,
        border: new UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          )
        ),
      
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
      ),
    );
  }
}
