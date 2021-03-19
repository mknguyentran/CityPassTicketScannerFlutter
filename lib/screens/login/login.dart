import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/screens/home_screen/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool _invalidEmail = false;
  bool _invalidPassword = false;
  var _passwordError = "Mật khẩu không hợp lệ";
  var _emailError = "Email không hợp lệ";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGrayBackground,
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                kDefaultPadding, 50, kDefaultPadding, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    child:Icon(CupertinoIcons.person_circle,size: 100,)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Soát vé CityPass",
                    style: TextStyle(
                        color: primaryDarkColor,
                        fontSize: 21,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    decoration: InputDecoration(
                        prefixIcon: Container(
                          width: 50,
                          child: Icon(Icons.email),
                        ),
                        labelText: "Tên đăng nhập",
                        errorStyle: TextStyle(fontSize: 15),
                        errorText: _invalidEmail ? _emailError : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: primaryDarkColor))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    obscureText: true,
                    controller: _passwordController,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    decoration: InputDecoration(
                        prefixIcon: Container(
                          width: 50,
                          child: Icon(Icons.lock),
                        ),
                        labelText: "Mật khẩu",
                        errorText: _invalidPassword ? _passwordError : null,
                        errorStyle: TextStyle(fontSize: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.red))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: RaisedButton(
                      color: primaryDarkColor,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
