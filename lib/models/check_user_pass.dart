import 'package:flutter_guid/flutter_guid.dart';

class CheckUserPassRequest {
  final String ticketTypeId, userPassID;

  CheckUserPassRequest(this.ticketTypeId, this.userPassID);
}

class CheckUserPassResponse {
  Guid id;
  String userPassId;
  DateTime expiredAt;
  bool isChildren;

  CheckUserPassResponse.fromJson(Map<String, dynamic> json)
      : id = Guid(json['id']),
        userPassId = json['userPassId'],
        expiredAt = DateTime.parse(json['userPass']['willExpireAt']),
        isChildren = json['userPass']['isChildren'];
}

enum CheckUserPassResult {
  INVALID,
  ERROR,
  NOT_AVAILABLE,
}
