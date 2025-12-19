import 'package:flutter/material.dart';

class Ticket {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String seat;
  final String ticketType;
  final IconData icon;
  final Color iconColor;

  Ticket({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.seat,
    required this.ticketType,
    required this.icon,
    required this.iconColor,
  });
}
