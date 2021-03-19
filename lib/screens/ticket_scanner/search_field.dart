import 'package:citypass_ticket_scanner/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    Key key,
    this.width = 300,
    this.height = 50,
    this.hintText,
    this.boxShadow,
    this.isButton = true,
    this.onSubmitted,
  }) : super(key: key);

  final double width, height;
  final String hintText;
  final List<BoxShadow> boxShadow;
  final bool isButton;
  final Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: boxShadow,
      ),
      child: TextField(
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            color: primaryDarkColor.withOpacity(0.6),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          suffixIcon: Icon(
            Icons.edit,
            color: primaryDarkColor,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
          ).add(
            EdgeInsets.only(top: 12),
          ),
        ),
      ),
    );
  }
}
