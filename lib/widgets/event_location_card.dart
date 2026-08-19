import 'package:flutter/material.dart';

class EventLocationCard extends StatefulWidget {
  final String venueAddress;

  const EventLocationCard({super.key, required this.venueAddress});

  @override
  EventLocationCardState createState() => EventLocationCardState();
}

class EventLocationCardState extends State<EventLocationCard> {
  final String _errorMessage = 'La carte est temporairement désactivée.';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Localisation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildMapContent(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.venueAddress, style: const TextStyle(color: Color.fromRGBO(117, 117, 117, 1))),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: null, // Button is disabled
                  icon: const Icon(Icons.navigation),
                  label: const Text('Itinéraire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: const Color.fromRGBO(158, 158, 158, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContent() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(238, 238, 238, 1),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color.fromRGBO(97, 97, 97, 1)),
          ),
        ),
      ),
    );
  }
}
