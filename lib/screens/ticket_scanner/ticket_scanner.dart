import 'dart:convert';
import 'dart:io';

import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/models/check_user_pass.dart';
import 'package:citypass_ticket_scanner/models/ticket_type.dart';
import 'package:citypass_ticket_scanner/screens/ticket_scanner/search_field.dart';
import 'package:citypass_ticket_scanner/service/check_user_pass.dart';
import 'package:citypass_ticket_scanner/service/ticket_type.dart';
import 'package:citypass_ticket_scanner/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;

class TicketScanner extends StatefulWidget {
  const TicketScanner({
    Key key,
  }) : super(key: key);
  @override
  _TicketScannerState createState() => _TicketScannerState();
}

class _TicketScannerState extends State<TicketScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  Color _backgroundColor = darkGrayBackground;
  Color _foregroundColor = textBlack;
  bool _flashIsOn = false, _isLoading = false;
  var _result;
  Future<List<TicketType>> _ticketTypeList;
  TicketType _currentTicket;
  String _userDeviceToken = "";

  @override
  void initState() {
    super.initState();
    _ticketTypeList = TicketTypeService().getCurrentAttractionTicketType();
  }

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

  void _playSuccessSound() {
    if (Platform.isAndroid) {
      // FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
    } else if (Platform.isIOS) {
      FlutterBeep.playSysSound(1394);
    }
  }

  void _playFailedSound() {
    if (Platform.isAndroid) {
      // FlutterBeep.playSysSound(AndroidSoundIDs.TONE_SUP_ERROR);
    } else if (Platform.isIOS) {
      FlutterBeep.playSysSound(iOSSoundIDs.JBL_Cancel);
    }
  }

  void _displayResult(var result) {
    var bgColor, fgColor;
    if (result != null) {
      print(result);
      if (result is CheckUserPassResponse) {
        bgColor = Colors.green;
        fgColor = Colors.white;
        _playSuccessSound();
      } else if (result is CheckUserPassResult) {
        bgColor = Colors.red[400];
        fgColor = Colors.white;
        _playFailedSound();
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
    initializeDateFormatting("vi_VN", null);
    SizeConfig().init(context);
    return FutureBuilder(
        future: _ticketTypeList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _currentTicket = (snapshot.data as List<TicketType>)[0];
            return LoadingOverlay(
              isLoading: _isLoading,
              color: Colors.black87,
              progressIndicator: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryLightColor),
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: _backgroundColor,
                appBar: _buildAppBar(snapshot.data),
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
                        child: Result(
                          result: _result,
                          foregroundColor: _foregroundColor,
                          onCancel: _removeResult,
                          onAccept: _acceptTicket,
                          notify: sendNotificationToDevice,
                          userDeviceToken: _userDeviceToken,
                          toggleLoading: toggleLoading,
                          showSnackbar: (snackBar) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryDarkColor, secondaryColor],
                    begin: Alignment.bottomCenter,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "CityPass Ticket Scanner",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        });
  }

  AppBar _buildAppBar(List<TicketType> ticketTypeList) {
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
          DropdownButton<TicketType>(
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
            onChanged: (TicketType selectedTicket) {
              if (selectedTicket != _currentTicket) {
                setState(
                  () {
                    _currentTicket = selectedTicket;
                  },
                );
              }
            },
            items: ticketTypeList
                .map<DropdownMenuItem<TicketType>>((TicketType value) {
              return DropdownMenuItem<TicketType>(
                value: value,
                child: Text(
                  value.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
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
        CheckUserPassRequest(_currentTicket.id.toString(), code);
    var result = await CheckUserPassService().checkUserPass(request);
    _displayResult(result);
    toggleLoading(false);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      toggleLoading(true);
      String tmp = scanData.code;
      List<String> tmpList = tmp.split(' ');
      CheckUserPassRequest request =
          CheckUserPassRequest(_currentTicket.id.toString(), tmpList[0]);
      var result = await CheckUserPassService().checkUserPass(request);
      // if (result is CheckUserPassResponse) {
      //   sendNotificationToDevice(tmpList[1], tmpList[0]);
      // }
      _userDeviceToken = tmpList[1];
      _displayResult(result);
      toggleLoading(false);
    });
  }

  Future<bool> _acceptTicket() async {
    bool isAccepted = false;
    try {
      toggleLoading(true);
      String ticketID = (_result as CheckUserPassResponse).id.toString();
      isAccepted = await CheckUserPassService().acceptUserPass(ticketID);
      toggleLoading(false);
    } catch (e, s) {
      print(s);
    } finally {
      toggleLoading(false);
    }
    return isAccepted;
  }

  void sendNotificationToDevice(String token, String id) async {
    var url = 'https://fcm.googleapis.com/fcm/send';
    var header = {
      "Content-Type": "application/json",
      "Authorization":
          "key=AAAAiDMS30E:APA91bHJGWSNc4YrYYX-Drg7-pjdVFNCnqI4Sr6Y3rPc17Mi5_U0CAklzgImy6E1Xd84EV4pEKZ9IrI_V_aIc7C3UWgP2oHseMWcAksas1ZFTFpmv9rPSLG3rVEQpghl_rwNN4Nr1zhc",
    };
    var currentTime = DateTime.now();
    var request = {
      "notification": {
        "title": "Sử dụng Pass thành công",
        "body": "Bạn đã sử dụng thành công Pass có ID $id vào lúc " +
            currentTime.toString(),
      },
      "priority": "high",
      "to": token,
    };

    await http.post(url, headers: header, body: json.encode(request));
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
    @required this.onCancel,
    @required this.onAccept,
    @required this.notify,
    @required this.toggleLoading,
    @required this.userDeviceToken,
    @required this.showSnackbar,
  })  : _foregroundColor = foregroundColor,
        super(key: key);

  final result;
  final Color _foregroundColor;
  final Function() onCancel, onAccept;
  final Function(String, String) notify;
  final Function(SnackBar) showSnackbar;
  final Function(bool) toggleLoading;
  final String userDeviceToken;

  String _getResultText(CheckUserPassResult result) {
    switch (result) {
      case CheckUserPassResult.NOT_AVAILABLE:
        return "Vé không hợp lệ";
        break;
      case CheckUserPassResult.INVALID:
        return "Không hợp lệ";
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
        CheckUserPassResponse _result = result;
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _result.isChildren ? "Vé trẻ em" : "Vé người lớn",
                  style: TextStyle(
                    color: _foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'ID: ${_result.userPassId}',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Hết hạn lúc: ${simpleDateAndTimeFormat.format(_result.expiredAt.add(Duration(hours: 7)))}',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
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
                        onPressed: () {
                          onCancel();
                          showSnackbar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(kDefaultPadding),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.white,
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Đã từ chối",
                                    style: TextStyle(
                                      fontSize: 21,
                                      color: Colors.red[400],
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.xmark,
                                    color: Colors.red[400],
                                    size: 21,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
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
                        onPressed: () async {
                          toggleLoading(true);
                          bool isAccepted = await onAccept();
                          if (isAccepted && userDeviceToken.trim().isNotEmpty) {
                            notify(userDeviceToken, _result.userPassId);
                          }
                          toggleLoading(false);
                          onCancel();
                          if (isAccepted) {
                            showSnackbar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(kDefaultPadding),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.white,
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Đã chấp nhận",
                                      style: TextStyle(
                                        fontSize: 21,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Icon(
                                      Icons.check_rounded,
                                      color: Colors.green,
                                      size: 21,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      } else if (result is CheckUserPassResult) {
        return GestureDetector(
          onTap: onCancel,
          child: Column(
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
          ),
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
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }
}
