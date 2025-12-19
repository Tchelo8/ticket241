
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:intl/date_symbol_data_local.dart';


class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  bool _isUpcoming = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  final List<Ticket> _upcomingTickets = [
    Ticket(
        title: "Entre Nous Bar",
        subtitle: "Concert Live",
        date: "Mar 29",
        time: "22:00",
        seat: "N/A",
        ticketType: "VIP x1",
        icon: Icons.music_note,
        iconColor: Colors.teal),
    Ticket(
        title: "CMS vs US Bitam",
        subtitle: "Ligue Nationale de Football",
        date: "Avr 05",
        time: "16:00",
        seat: "Rangée 12, Siège 5",
        ticketType: "Normal x2",
        icon: Icons.sports_soccer,
        iconColor: Colors.orange),
  ];

  final List<Ticket> _pastTickets = [
    Ticket(
        title: "Concert L'oiseau rare",
        subtitle: "Showcase Exclusif",
        date: "Fév 14",
        time: "20:00",
        seat: "Table 5",
        ticketType: "VIP x2",
        icon: Icons.star,
        iconColor: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          'Billets',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildTabs(),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _isUpcoming
                  ? _buildTicketList(_upcomingTickets, key: const ValueKey("upcoming"))
                  : _buildTicketList(_pastTickets, key: const ValueKey("past")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mars 2024",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () {},
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        DatePicker(
          DateTime.now(),
          initialSelectedDate: DateTime.now(),
          selectionColor: const Color(0xFF007BFF),
          selectedTextColor: Colors.white,
          height: 90,
          locale: "fr_FR",
          dayTextStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          monthTextStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          dateTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),

        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
         padding: const EdgeInsets.all(4),
         decoration: BoxDecoration(
           color: Colors.grey[200],
           borderRadius: BorderRadius.circular(10)
         ),
        child: Row(
          children: [
            _buildTab("À venir", _isUpcoming),
            _buildTab("Passés", !_isUpcoming),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isUpcoming = text == "À venir";
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              )
            ] : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF007BFF) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList(List<Ticket> tickets, {Key? key}) {
    return ListView.builder(
      key: key,
      itemCount: tickets.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        return _buildTicketCard(tickets[index]);
      },
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
           Padding(
             padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(ticket.subtitle, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                 Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ticket.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(ticket.icon, color: ticket.iconColor, size: 28),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(
              color: Colors.grey,
              height: 1,
            ),
          ),
          Padding(
             padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTicketInfo('Heure', ticket.time),
                _buildTicketInfo('Siège', ticket.seat),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(ticket.ticketType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTicketInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
