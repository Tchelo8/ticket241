
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
  final double price;
  final String reference;
  final DateTime eventStartDate;

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
    required this.price,
    required this.reference,
    required this.eventStartDate,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'eventName': eventName,
        'location': location,
        'date': date,
        'time': time,
        'status': status,
        'ticketCount': ticketCount,
        'daysLeft': daysLeft,
        'isUpcoming': isUpcoming,
        'price': price,
        'reference': reference,
        'eventStartDate': eventStartDate.toIso8601String(),
      };

  factory EventTicket.fromJson(Map<String, dynamic> json) => EventTicket(
        imagePath: json['imagePath'] as String,
        eventName: json['eventName'] as String,
        location: json['location'] as String,
        date: json['date'] as String,
        time: json['time'] as String,
        status: json['status'] as String,
        ticketCount: json['ticketCount'] as int,
        daysLeft: json['daysLeft'] as int,
        isUpcoming: json['isUpcoming'] as bool,
        price: (json['price'] as num).toDouble(),
        reference: json['reference'] as String,
        eventStartDate: DateTime.parse(json['eventStartDate'] as String),
      );
}
