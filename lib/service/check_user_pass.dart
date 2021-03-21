import 'dart:convert';

import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/models/check_user_pass.dart';
import 'package:http/http.dart' as http;

class CheckUserPassService {
  Future<dynamic> checkUserPass(CheckUserPassRequest request) async {
    var queryParameters = {
      'UserPassId': request.userPassID,
      'TicketTypeId': request.ticketTypeId,
    };
    var uri = Uri.https(
      BASE_URL,
      CHECK_USER_PASS,
      queryParameters,
    );
    http.Response response = await http.get(uri);

    var raw = json.decode(response.body);
    if (response.statusCode == 200) {
      if (raw is bool) {
        return CheckUserPassResult.NOT_AVAILABLE;
      } else {
        try {
          CheckUserPassResponse result = CheckUserPassResponse.fromJson(raw);
          return result;
        } catch (e, s) {
          print(s);
          return CheckUserPassResult.ERROR;
        }
      }
    } else if (response.statusCode == 400) {
      return CheckUserPassResult.INVALID;
    }
  }
}
