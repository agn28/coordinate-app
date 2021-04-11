import 'package:flutter/material.dart';

//urls
// const String apiUrl = 'http://b41739a1a57c.ngrok.io/api/v1/';
// const String apiUrl = 'https://coordinate-api.monarko.com/api/v1/';
const String apiUrl = 'https://brac-api.ghrucoordinate.com/api/v1/';

const String gsBucket = 'gs://brac-coordinate.appspot.com';

var httpRequestTimeout = 10;

const kTextInputColorGrey = Color(0xFFE5E5E5);
const kPrimaryColor = Color(0xFF01579B);

const kPrimaryLight = Color(0x5001579B);
const kPrimaryTextFillColor = Color(0xFF00508f);
const kLightPrimaryColor = Color(0xFFebf2f7);
const kPrimaryRedColor = Color(0xFFD92647);
const kPrimaryGreenColor = Color(0xFF2E7D32);
const kPrimaryYellowColor = Color(0xFFF79421);
const kBorderLight = Color(0x50000000);
const kBorderLighter = Color(0x20000000);
const kBottomNavigationGrey = Color(0xFFF0F0F0);
const kStepperDot = Color(0x16000000);
const kWhite70 = Color(0x70FFFFFF);
const kSuccessColor = Color(0xFF66BB6A);

const kLightButton = Color(0xFFE1F5FE);
const kErroText = Color(0xFFFFB8B8);
const kSecondaryTextField = Color(0xFFE8E8E8);

const kBackgroundGrey = Color(0xFFF9F9F9);
const kPrimaryAmberColor = Color(0xFFFFbf00);
const kRedColor = Color(0xFFFF0000);
const kGreenColor = Color(0xFF007000);
const kPrimaryBlueColor = Color(0xFFa5be40);
const kPrimaryDeepRedColor = Color(0xFF8b0000);

const kTextGrey = Color(0x65000000);
const kShapeColorGreen = Color(0xFF98C645);
const kTableBorderGrey = Color(0x12000000);
const kBorderGrey = Color(0x54000000);

const kLightBlack = Colors.black87;
const kWarningColor = Color(0xFFFFF8E1);
Color kBtnOrangeColor = Color(0xFFFF781f);

class ColorUtils {
  static var statusColor = {
    'AMBER': kPrimaryAmberColor,
    'GREEN': kGreenColor,
    'BLUE': kPrimaryBlueColor,
    'RED': kRedColor,
    'DEEP-RED': kPrimaryDeepRedColor,
    'DARK-RED': kPrimaryDeepRedColor,
    'GRAY': kBorderGrey,
  };
}
