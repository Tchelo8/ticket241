
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:shimmer/shimmer.dart';

class TicketsScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const TicketsScreen({super.key, required this.onNavigate});

  @override
  TicketsScreenState createState() => TicketsScreenState();
}

class TicketsScreenState extends State<TicketsScreen> {
  bool _isUpcoming = true;

  final List<EventTicket> _tickets = [];

  @override
  Widget build(BuildContext context) {
    final upcomingTickets = _tickets.where((t) => t.isUpcoming).toList();
    final pastTickets = _tickets.where((t) => !t.isUpcoming).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mes Billets',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isUpcoming
                    ? (upcomingTickets.isEmpty
                        ? _buildEmptyState()
                        : _buildTicketList(upcomingTickets,
                            key: const ValueKey("upcoming")))
                    : (pastTickets.isEmpty
                        ? _buildEmptyState()
                        : _buildTicketList(pastTickets, key: const ValueKey("past"))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Tickets.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun billet pour le moment',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(0, 0, 0, 0.54)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Il semble que vous n\'ayez pas encore de billets. Explorez les événements pour en trouver !',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color.fromRGBO(0, 0, 0, 0.45)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.onNavigate(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child:
                const Text('Explorer les événements', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, EventTicket ticket) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildBottomSheetOptions(context, ticket),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBottomSheetOptions(BuildContext context, EventTicket ticket) {
    List<Widget> options;

    if (ticket.isUpcoming) {
      options = [
        ListTile(
          leading: const Icon(Icons.replay, color: Colors.black87),
          title: const Text('Commander à nouveau'),
          onTap: () {
            context.pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.cancel_outlined, color: Color.fromRGBO(211, 47, 47, 1)),
          title: const Text('Annuler la réservation',
              style: TextStyle(color: Color.fromRGBO(211, 47, 47, 1))),
          onTap: () {
            context.pop();
          },
        ),
      ];
    } else {
      options = [
        ListTile(
          leading: const Icon(Icons.download_outlined, color: Colors.black87),
          title: const Text('Télécharger le reçu'),
          onTap: () {
            context.pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.archive_outlined, color: Colors.black87),
          title: const Text('Archiver'),
          onTap: () {
            context.pop();
          },
        ),
      ];
    }

    options.addAll([
      const Divider(height: 20, indent: 20, endIndent: 20, thickness: 1),
      ListTile(
        leading: const Icon(Icons.close, color: Colors.black87),
        title: const Text('Fermer'),
        onTap: () => context.pop(),
      ),
    ]);

    return options;
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(238, 238, 238, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTab("À venir", _isUpcoming),
          _buildTab("Passés", !_isUpcoming),
        ],
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
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color.fromRGBO(158, 158, 158, 0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    )
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF1E90FF)
                  : const Color.fromRGBO(117, 117, 117, 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList(List<EventTicket> tickets, {Key? key}) {
    return AnimationLimiter(
      key: key,
      child: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildTicketCard(tickets[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(EventTicket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(238, 238, 238, 1)),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(158, 158, 158, 0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: ticket.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: const Color.fromRGBO(224, 224, 224, 1),
                    highlightColor: const Color.fromRGBO(245, 245, 245, 1),
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/logoblanc.png', // Local fallback image
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color.fromRGBO(158, 158, 158, 1), size: 16),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(ticket.location,
                              style: const TextStyle(
                                  color: Color.fromRGBO(158, 158, 158, 1)),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ticket.isUpcoming
                                ? const Color.fromRGBO(76, 175, 80, 0.1)
                                : const Color.fromRGBO(255, 152, 0, 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticket.status,
                            style: TextStyle(
                              color: ticket.isUpcoming
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.eventName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text("${ticket.date}, ${ticket.time}",
                        style: const TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.54), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(
              height: 1, color: Color.fromRGBO(158, 158, 158, 1), indent: 20, endIndent: 20),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoChip(
                  "${ticket.ticketCount} billet${ticket.ticketCount > 1 ? 's' : ''}"),
              if (ticket.isUpcoming) _buildInfoChip("J-${ticket.daysLeft}"),
              const Spacer(),
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (ticket.isUpcoming) {
                      context.push('/pdf-viewer');
                    } else {
                      // Handle 'Laisser un avis' action
                    }
                  },
                  icon: Icon(
                      ticket.isUpcoming
                          ? Icons.download_outlined
                          : Icons.rate_review_outlined,
                      size: 20),
                  label: Text(
                    ticket.isUpcoming ? 'Telecharger' : 'Laisser un avis',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromRGBO(30, 144, 255, 0.1),
                    foregroundColor: const Color(0xFF1E90FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromRGBO(224, 224, 224, 1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Color.fromRGBO(0, 0, 0, 0.54)),
                  onPressed: () => _showOptionsBottomSheet(context, ticket),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(158, 158, 158, 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(0, 0, 0, 0.54))),
    );
  }
}
