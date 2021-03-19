import 'dart:io';

import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/screens/login/login.dart';
import 'package:citypass_ticket_scanner/screens/ticket_scanner/search_field.dart';
import 'package:citypass_ticket_scanner/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class TicketScanner extends StatefulWidget {
  @override
  _TicketScannerState createState() => _TicketScannerState();
}

class _TicketScannerState extends State<TicketScanner> {
  List<String> ticketTypes = ["Vé Đầm Sen Khô", "Vé Đầm Sen Nước"];
  String _currentTicket = "Vé Đầm Sen Khô";
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;
  Color _backgroundColor = darkGrayBackground;
  Color _foregroundColor = textBlack;
  bool flashIsOn = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  void _displayResult() {
    var bgColor, fgColor;
    switch (result.code) {
      case RESULT_ADULT_TICKET:
        bgColor = Colors.green;
        fgColor = Colors.white;
        FlutterBeep.playSysSound(1394);
        break;
      case RESULT_CHILD_TICKET:
        bgColor = Colors.green;
        fgColor = Colors.white;
        FlutterBeep.playSysSound(1394);
        break;
      case RESULT_EXPIRED:
        bgColor = Colors.red[400];
        fgColor = Colors.white;
        FlutterBeep.playSysSound(iOSSoundIDs.JBL_Cancel);
        break;
      case RESULT_NOT_AVAILABLE:
        bgColor = Colors.red[400];
        fgColor = Colors.white;
        FlutterBeep.playSysSound(iOSSoundIDs.JBL_Cancel);
        break;
      case ALREADY_SCANNED:
        bgColor = Colors.yellow[700];
        fgColor = textBlack;
        FlutterBeep.playSysSound(iOSSoundIDs.JBL_NoMatch);
        break;
      default:
    }
    setState(() {
      _backgroundColor = bgColor;
      _foregroundColor = fgColor;
    });
  }

  void _submitCode(String code) {
    setState(() {
      if (code.toUpperCase() == "ABC001") {
        result = Barcode(RESULT_ADULT_TICKET, BarcodeFormat.qrcode, [1, 2]);
      } else if (code.toUpperCase() == "ABC002") {
        result = Barcode(RESULT_CHILD_TICKET, BarcodeFormat.qrcode, [1, 2]);
      } else {
        result = Barcode(RESULT_NOT_AVAILABLE, BarcodeFormat.qrcode, [1, 2]);
      }
    });
    _displayResult();
    controller.pauseCamera();
  }

  void _removeResult() {
    setState(() {
      result = null;
      _backgroundColor = darkGrayBackground;
      _foregroundColor = textBlack;
    });
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding, vertical: 15),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SearchField(
                  hintText: "Nhập mã thủ công",
                  boxShadow: [kDefaultShadow],
                  onSubmitted: (value) => _submitCode(value),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      iconSize: 35,
                      icon: flashIsOn
                          ? Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              child: Icon(
                                Icons.flash_on_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              child: Icon(
                                Icons.flash_off_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                      onPressed: _onToggleFlash,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: GestureDetector(
                  onTap: _removeResult,
                  child: Result(
                    result: result,
                    foregroundColor: _foregroundColor,
                    onButtonPressed: _removeResult,
                  )),
            )
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    var _brightness = Brightness.dark;
    return AppBar(
      shadowColor: secondaryColor,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryDarkColor, secondaryColor]),
        ),
      ),
      brightness: _brightness,
      elevation: 5,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Loại vé hiện tại".toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          ),
          VerticalSpacing(of: 3),
          DropdownButton<String>(
            isDense: true,
            dropdownColor: primaryLightColor,
            value: _currentTicket,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            underline: VerticalSpacing(
              of: 0,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "SFProRounded",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            onChanged: (String newValue) {
              setState(() {
                _removeResult();
                _currentTicket = newValue;
              });
            },
            items: ticketTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      _displayResult();
      controller.pauseCamera();
    });
  }

  void _onToggleFlash() async {
    await controller.toggleFlash();
    var flashStatus = await controller.getFlashStatus();
    setState(() {
      flashIsOn = flashStatus;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class Result extends StatelessWidget {
  const Result({
    Key key,
    @required this.result,
    @required Color foregroundColor,
    @required this.onButtonPressed,
  })  : _foregroundColor = foregroundColor,
        super(key: key);

  final Barcode result;
  final Color _foregroundColor;
  final Function() onButtonPressed;

  String _getResultText(String result) {
    switch (result) {
      case RESULT_ADULT_TICKET:
        return "Vé người lớn";
        break;
      case RESULT_CHILD_TICKET:
        return "Vé trẻ em";
        break;
      case RESULT_EXPIRED:
        return "Combo đã hết hạn";
        break;
      case RESULT_NOT_AVAILABLE:
        return "Combo không khả dụng cho vé này";
        break;
      case ALREADY_SCANNED:
        return "Combo đã từng được sử dụng tại đây";
        break;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      if (result.code == RESULT_ADULT_TICKET ||
          result.code == RESULT_CHILD_TICKET) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _getResultText(result.code),
                  style: TextStyle(
                    color: _foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'ID: ABC001',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Hết hạn ngày 31/03/2021',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: getProportionateScreenWidth(150),
                      height: getProportionateScreenHeight(50),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                fontFamily: "SFProRounded",
                                fontSize: 20,
                              ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            )),
                        child: Text(
                          "Từ chối",
                          style: TextStyle(),
                        ),
                        onPressed: onButtonPressed,
                      ),
                    ),
                    SizedBox(
                      width: getProportionateScreenWidth(150),
                      height: getProportionateScreenHeight(50),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                fontFamily: "SFProRounded",
                                fontSize: 20,
                              ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.green),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            )),
                        child: Text("Chấp nhận"),
                        onPressed: onButtonPressed,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      } else if (result.code == RESULT_EXPIRED ||
          result.code == RESULT_NOT_AVAILABLE) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getResultText(result.code),
              style: TextStyle(
                color: _foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      } else if (result.code == ALREADY_SCANNED) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _getResultText(result.code),
                  style: TextStyle(
                    color: _foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Đã quét vào lúc 09:25, 18/03/2021',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mã QR không hợp lệ',
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 30,
              ),
            ),
          ],
        );
      }
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đặt mã QR nằm trong khung',
            style: TextStyle(
              color: fadedTextColor,
              fontSize: 30,
            ),
          ),
        ],
      );
    }
  }
}
