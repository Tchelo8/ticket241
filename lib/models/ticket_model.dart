
class EventTicket {
  final String imagePath;
  final String eventName;
  final String location;
  final String date;
  final String time;
  final String status; // "Paid", "Completed"
  final int ticketCount;
  final int daysLeft;
  final bool isUpcoming;

  EventTicket({
    required this.imagePath,
    required this.eventName,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.ticketCount,
    required this.daysLeft,
    required this.isUpcoming,
  });
}
