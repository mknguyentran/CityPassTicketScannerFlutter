import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/size_config.dart';
import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader(
    this.adultAmount,
    this.childrenAmount, {
    Key key,
  }) : super(key: key);

  final int adultAmount, childrenAmount;

  @override
  Widget build(BuildContext context) {
    var _boxHeight = 150.0;
    return Column(
      children: [
        Text(
          "Đã quét hôm nay",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: subtitleTextColor),
        ),
        VerticalSpacing(of: 20),
        Row(
          children: [
            Expanded(
              flex: 19,
              child: Container(
                padding: EdgeInsets.all(15),
                height: _boxHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [kDefaultShadow],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      adultAmount.toString(),
                      style: TextStyle(fontSize: 50, color: primaryDarkColor),
                    ),
                    VerticalSpacing(of: 30),
                    Text(
                      "Vé người lớn",
                      style: TextStyle(fontSize: 20, color: primaryDarkColor),
                    )
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 19,
              child: Container(
                height: _boxHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [kDefaultShadow],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      childrenAmount.toString(),
                      style: TextStyle(fontSize: 50, color: primaryDarkColor),
                    ),
                    VerticalSpacing(of: 30),
                    Text(
                      "Vé trẻ em",
                      style: TextStyle(fontSize: 20, color: primaryDarkColor),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
