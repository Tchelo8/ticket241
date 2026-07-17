import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart' as geocoding; // Temporarily disabled
import 'package:url_launcher/url_launcher.dart';

class EventLocationCard extends StatefulWidget {
  final String venueAddress;

  const EventLocationCard({Key? key, required this.venueAddress}) : super(key: key);

  @override
  _EventLocationCardState createState() => _EventLocationCardState();
}

class _EventLocationCardState extends State<EventLocationCard> {
  // GoogleMapController? _mapController;
  // Set<Marker> _markers = {};
  // LatLng? _eventLocation;
  final String _errorMessage = 'La carte est temporairement désactivée.';

  @override
  void initState() {
    super.initState();
    // _geocodeAddress(); // Temporarily disabled
  }

  /* // Temporarily disabled
  Future<void> _geocodeAddress() async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(widget.venueAddress);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _eventLocation = LatLng(location.latitude, location.longitude);
          _markers.add(
            Marker(
              markerId: const MarkerId('eventLocation'),
              position: _eventLocation!,
              infoWindow: const InfoWindow(title: 'Lieu de l'événement'),
            ),
          );
        });
      } else {
        setState(() {
          _errorMessage = 'Adresse introuvable.';
        });
      }
    } catch (e) {
      print('Error geocoding address: $e');
      setState(() {
        _errorMessage = 'Erreur de chargement de la carte.';
      });
    }
  }
  */

  Future<void> _launchMaps() async {
    // Disabled functionality
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
                Text(widget.venueAddress, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: null, // Button is disabled
                  icon: const Icon(Icons.navigation),
                  label: const Text('Itinéraire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Colors.grey,
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
        color: Colors.grey[200],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
