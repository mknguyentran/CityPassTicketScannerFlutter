import 'package:citypass_ticket_scanner/constants.dart';
import 'package:citypass_ticket_scanner/models/ticket_scanning_entry.dart';
import 'package:citypass_ticket_scanner/size_config.dart';
import 'package:flutter/material.dart';

class TicketScanningEntryList extends StatelessWidget {
  const TicketScanningEntryList(
    this.child, {
    Key key,
  }) : super(key: key);

  final List<TicketScanningEntry> child;

  @override
  Widget build(BuildContext context) {
    var _fontSize = 15.0;
    List<TicketScanningEntry> list = List.from(child);
    list.sort((a, b) {
      return b.scannedAt.compareTo(a.scannedAt);
    });
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ID: ${list[index].id}".toUpperCase(),
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      Text(
                          simpleDateAndTimeFormat.format(list[index].scannedAt),
                          style: TextStyle(fontSize: _fontSize)),
                    ],
                  ),
                  VerticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(list[index].ticketName,
                          style: TextStyle(fontSize: _fontSize)),
                      if (list[index].status == RESULT_SUCCESS)
                        Text("Thành công",
                            style: TextStyle(
                                fontSize: _fontSize, color: Colors.green)),
                      if (list[index].status == RESULT_REJECTED)
                        Text("Từ chối",
                            style: TextStyle(
                                fontSize: _fontSize,
                                color: Colors.yellow[700])),
                      if (list[index].status == RESULT_FAILED)
                        Text("Thất bại",
                            style: TextStyle(
                                fontSize: _fontSize, color: Colors.red[300])),
                    ],
                  )
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(
            color: darkGrayBackground,
            height: 0,
            thickness: 2,
          ),
          itemCount: list.length,
        ),
      ),
    );
  }
}
