import 'dart:io';

import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/models/check_user_pass.dart';
import 'package:citypass_ticket_scanner/screens/ticket_scanner/search_field.dart';
import 'package:citypass_ticket_scanner/service/check_user_pass.dart';
import 'package:citypass_ticket_scanner/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:loading_overlay/loading_overlay.dart';

class TicketScanner extends StatefulWidget {
  @override
  _TicketScannerState createState() => _TicketScannerState();
}

class _TicketScannerState extends State<TicketScanner> {
  List<String> ticketTypes = ["Vé Đầm Sen Khô", "Vé Đầm Sen Nước"];
  String _currentTicket = "Vé Đầm Sen Khô";
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  Color _backgroundColor = darkGrayBackground;
  Color _foregroundColor = textBlack;
  bool _flashIsOn = false, _isLoading = false;
  var _result;

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

  void _displayResult(var result) {
    var bgColor, fgColor;
    if (result != null) {
      print(result);
      if (result is CheckUserPassResponse) {
        bgColor = Colors.green;
        fgColor = Colors.white;
        FlutterBeep.playSysSound(1394);
      } else if (result is CheckUserPassResult) {
        bgColor = Colors.red[400];
        fgColor = Colors.white;
        FlutterBeep.playSysSound(iOSSoundIDs.JBL_Cancel);
      } else {
        bgColor = darkGrayBackground;
        fgColor = textBlack;
      }
      setState(() {
        _backgroundColor = bgColor;
        _foregroundColor = fgColor;
        _result = result;
      });
    }
  }

  void _removeResult() {
    setState(() {
      _result = null;
      _backgroundColor = darkGrayBackground;
      _foregroundColor = textBlack;
    });
    controller.resumeCamera();
  }

  void toggleLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      color: Colors.black87,
      progressIndicator: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(primaryLightColor),
      ),
      child: Scaffold(
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
                        icon: _flashIsOn
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
                      result: _result,
                      foregroundColor: _foregroundColor,
                      onButtonPressed: _removeResult,
                    ),
                  )),
            ],
          ),
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

  void _submitCode(String code) async {
    controller.pauseCamera();
    toggleLoading(true);
    CheckUserPassRequest request =
        CheckUserPassRequest(CURRENT_TICKET_TYPE, code);
    var result = await CheckUserPassService().checkUserPass(request);
    _displayResult(result);
    toggleLoading(false);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      toggleLoading(true);
      CheckUserPassRequest request =
          CheckUserPassRequest(CURRENT_TICKET_TYPE, scanData.code);
      var result = await CheckUserPassService().checkUserPass(request);
      _displayResult(result);
      toggleLoading(false);
    });
  }

  void _onToggleFlash() async {
    await controller.toggleFlash();
    var flashStatus = await controller.getFlashStatus();
    setState(() {
      _flashIsOn = flashStatus;
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

  final result;
  final Color _foregroundColor;
  final Function() onButtonPressed;

  String _getResultText(CheckUserPassResult result) {
    switch (result) {
      case CheckUserPassResult.NOT_AVAILABLE:
        return "Vé không hợp lệ";
        break;
      case CheckUserPassResult.INVALID:
        return "Mã QR không hợp lệ";
        break;
      case CheckUserPassResult.ERROR:
        return "Đã có lỗi xảy ra. Vui lòng thủ lại. ";
        break;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      if (result is CheckUserPassResponse) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Hợp lệ",
                  style: TextStyle(
                    color: _foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'ID: ${(result as CheckUserPassResponse).userPassId}',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (result is CheckUserPassResult) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getResultText(result),
              style: TextStyle(
                color: _foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
              textAlign: TextAlign.center,
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
