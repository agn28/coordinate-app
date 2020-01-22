import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

class PrimaryTextField extends StatefulWidget {
  PrimaryTextField({this.prefixIcon, this.suffixIcon, this.hintText, this.topPaadding, this.bottomPadding, this.controller, this.name, this.validation, this.type, this.onTap});

  final Icon prefixIcon;
  final Icon suffixIcon;
  final String hintText;
  final double topPaadding;
  final double bottomPadding;
  final TextEditingController controller;
  final String name;
  final bool validation;
  final TextInputType type;
  final Function onTap;

  @override
  _PrimaryTextFieldState createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: widget.onTap,
      style: TextStyle(color: kPrimaryColor, fontSize: 20.0,),
      controller: widget.controller,
      validator: widget.validation != null && widget.validation ? (value) => _validateInputs(value) : null,
      autovalidate: _autoValidate,
      onChanged: (value) => {
          setState(() => _autoValidate = true)
      },
      keyboardType: widget.type,
      inputFormatters: widget.type != null ? _getInputFormatters() : null,
      decoration: InputDecoration(
        counterText: ' ',
        contentPadding: EdgeInsets.only(top: widget.topPaadding != null ? widget.topPaadding : 25.0, bottom: widget.bottomPadding != null ? widget.bottomPadding : 25.0, left: 10, right: 10),
        prefixIcon: widget.prefixIcon,
        filled: true,
        fillColor: kSecondaryTextField,
        border: new UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          )
        ),
      
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.black45, fontSize: 19.0),
      ),
    );
  }

  _validateInputs(value) {
    if (value.isEmpty) {
      String field = widget.name != null ? widget.name : 'This field';
      return '$field is required';
    }
    else if (widget.name == 'Date') {
      return _validateDate(value);
    }
    else if (widget.name == 'Month') {
      return _validateMonth(value);
    }
    else if (widget.name == 'Year') {
      return _validateYear(value);
    }
    return null;
  }

  _getInputFormatters() {
    var limit = -1;
    if (widget.name == 'Date' || widget.name == 'Month') {
      limit = 2;
    }
    else if (widget.name == 'Year') {
      limit = 4;
    }

    return <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(limit)];
  }

  _validateMonth(value) {
    if (int.parse(value) > 12) {
      return "Month should be under 12";
    }
  }

  _validateYear(value) {
    var year = DateTime.now().year;
    if (value.toString().length < 4) {
      return 'Year must be 4 digit';
    }
    if (int.parse(value) > year) {
      return 'Year should be under $year';
    }
  }

  _validateDate(value) {
    print('validate');
    if (int.parse(value) > 31) {
      return "Date should be under 31";
    }
  }
}
