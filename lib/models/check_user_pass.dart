import 'package:flutter_guid/flutter_guid.dart';

class CheckUserPassRequest {
  final String ticketTypeId, userPassID;

  CheckUserPassRequest(this.ticketTypeId, this.userPassID);
}

class CheckUserPassResponse {
  String usedAt;
  String userPassId;
  Object userPass;
  String ticketTypeId;
  String ticketType;
  Guid id;

  CheckUserPassResponse.fromJson(Map<String, dynamic> json)
      : id = Guid(json['id']),
        usedAt = json['usedAt'],
        userPassId = json['userPassId'],
        userPass = json['userPass'],
        ticketTypeId = json['ticketTypeId'],
        ticketType = json['ticketType'];
}

enum CheckUserPassResult {
  INVALID,
  ERROR,
  NOT_AVAILABLE,
}
