import 'dart:convert';

import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/models/check_user_pass.dart';
import 'package:citypass_ticket_scanner/models/ticket_type.dart';
import 'package:http/http.dart' as http;

class TicketTypeService {
  Future<List<TicketType>> getCurrentAttractionTicketType() async {
    var queryParameters = {
      'Attraction': CURRENT_ATTRACTION,
    };
    var uri = Uri.https(
      BASE_URL,
      TICKET_TYPE_PATH,
      queryParameters,
    );
    List<TicketType> result = [];
    http.Response response = await http.get(uri);

    var raw = json.decode(response.body);
    Iterable resultList = raw["data"];
    try {
      result = List<TicketType>.from(
        resultList.map(
          (e) => TicketType.formJson(e),
        ),
      );
    } catch (e, s) {
      print(s);
    }
    return result;
  }
}
