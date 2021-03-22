import 'package:flutter_guid/flutter_guid.dart';

class TicketType {
  final Guid id;
  final String name;

  TicketType(this.id, this.name);
  
  TicketType.formJson(Map<String, dynamic> json)
      : this.id = new Guid(json['id']),
        this.name = json['name'];
}
