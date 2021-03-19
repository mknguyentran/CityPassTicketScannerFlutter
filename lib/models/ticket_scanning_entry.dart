class TicketScanningEntry {
  final String id, ticketName;
  final DateTime scannedAt;
  final int status;

  TicketScanningEntry(this.id, this.scannedAt, this.status,
      [this.ticketName]);
}

const int RESULT_SUCCESS = 1;
const int RESULT_FAILED = 2;
const int RESULT_REJECTED = 3;
