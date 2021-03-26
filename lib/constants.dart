import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kPrimaryColor = Color(0xFF3E4067);
const kTextColor = Color(0xFF3F4168);
const kIconColor = Color(0xFF5E5E5E);
const kWhiteIconColor = Color(0xFFFFFFFF);
const primaryLightColor = Color(0xFFFF9900);
const primaryDarkColor = Color(0xFFEB6236);
const secondaryColor = Color(0xFFFF9900);
const orangeBackgroundColor = Color(0xFFFFE5BD);
const lightGreenBackgroundColor = Color(0xFFD5EED1);
const darkBackgroundColor = Color(0xFF2B5525);
const textBlack = Color(0xFF212121);
const subtitleTextColor = Color(0xFF818884);
const fadedTextColor = Color(0xFFC4C4C4);
const lightGray = Color(0xFFA5A5A5);
const lightGrayBackground = Color(0xFFF5F5F5);
const darkGrayBackground = Color(0xFFebecf0);
const dividerColor = Color(0xFFECECEC);
const starYellowColor = Color(0xFFF2A33A);

const defaultTextStyle = TextStyle(
  fontFamily: "SFProRounded",
  color: textBlack,
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

const kDefaultPadding = 20.0;

final vndCurrencyFormat =
    new NumberFormat.currency(locale: "vi_VN", symbol: "₫");

final kPopShadow = BoxShadow(
  offset: Offset(0, 0),
  blurRadius: 50,
  color: Color(0xFFB0B0B0).withOpacity(0.90),
);

final kDefaultShadow = BoxShadow(
  offset: Offset(4, 4),
  blurRadius: 10,
  color: Color(0xFFD1D1D1).withOpacity(0.7),
);

final topShadow = BoxShadow(
  offset: Offset(0, 0),
  blurRadius: 5,
  color: Color(0xFFAAAAAA).withOpacity(0.7),
);

final smallShadow = BoxShadow(
  offset: Offset(0, 2),
  blurRadius: 3,
  color: Color(0xFFA0A0A0).withOpacity(0.56),
);

final textShadow = BoxShadow(
  offset: Offset(0, 3),
  blurRadius: 10,
  color: Color(0xFF000000),
);

final DateFormat simpleDateFormat = new DateFormat("d LLL y", "vi_VN");
final DateFormat simpleDateAndTimeFormat =
    new DateFormat.Hm("vi_VN").addPattern(", d LLL y");

//Đổi cái này theo tên địa điểm rồi restart app
const CURRENT_ATTRACTION = "Bảo tàng tranh 3D Art in us";

