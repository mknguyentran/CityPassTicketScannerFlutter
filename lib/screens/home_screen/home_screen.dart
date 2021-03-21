import 'dart:math';

import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/mockup_data/mockup_ticket_scanning_entry.dart';
import 'package:citypass_ticket_scanner/models/check_user_pass.dart';
import 'package:citypass_ticket_scanner/models/ticket_scanning_entry.dart';
import 'package:citypass_ticket_scanner/screens/home_screen/components/ticket_scanning_entry_list.dart';
import 'package:citypass_ticket_scanner/screens/home_screen/components/today_header.dart';
import 'package:citypass_ticket_scanner/screens/login/login.dart';
import 'package:citypass_ticket_scanner/screens/ticket_scanner/ticket_scanner.dart';
import 'package:citypass_ticket_scanner/service/check_user_pass.dart';
import 'package:citypass_ticket_scanner/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> ticketTypes = ["Vé Đầm Sen Khô", "Vé Đầm Sen Nước"];
  String _currentTicket = "Vé Đầm Sen Khô";
  List<TicketScanningEntry> _currentEntryList;
  int _adultAmount, _childrenAmount;
  Random _random = new Random();

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Đã hết giờ nhận khách'),
          actions: [
            TextButton(
              child: Text('Hủy'.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentEntryList = entryList1;
    _adultAmount = _random.nextInt(200) + 50;
    _childrenAmount = _random.nextInt(200) + 50;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("vi_VN", null);
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: darkGrayBackground,
      appBar: _buildAppBar(),
      floatingActionButton: ScanButton(
        onLongTap: _showMyDialog,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: 20,
        ),
        child: Column(
          children: [
            TodayHeader(_adultAmount, _childrenAmount),
            VerticalSpacing(),
            TicketScanningEntryList(_currentEntryList),
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
      titleSpacing: 15,
      centerTitle: false,
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
              setState(
                () {
                  _currentTicket = newValue;
                  if (newValue == ticketTypes[0]) {
                    _currentEntryList = entryList1;
                  } else {
                    _currentEntryList = entryList2;
                  }
                  _adultAmount = _random.nextInt(200) + 50;
                  _childrenAmount = _random.nextInt(200) + 50;
                },
              );
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
      actions: [
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) {
                    return LoginForm();
                  },
                ),
              );
            },
            child: Text(
              "Đăng xuất".toUpperCase(),
              style:
                  TextStyle(color: Colors.red[50], fontWeight: FontWeight.bold),
            ))
      ],
    );
  }
}

class ScanButton extends StatelessWidget {
  const ScanButton({
    Key key,
    this.onLongTap,
  }) : super(key: key);

  final Function() onLongTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        onLongTap();
      },
      child: FloatingActionButton.extended(
        backgroundColor: primaryLightColor,
        onPressed: () async {
          if (await Permission.camera.request().isGranted) {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) {
                return TicketScanner();
              }),
            );
          }
        },
        icon: Icon(
          CupertinoIcons.qrcode_viewfinder,
          size: 35,
        ),
        label: Text(
          "Soát vé".toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
