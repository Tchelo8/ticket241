import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:url_launcher/url_launcher.dart';

class EventLocationCard extends StatefulWidget {
  final String venueAddress;

  const EventLocationCard({Key? key, required this.venueAddress}) : super(key: key);

  @override
  _EventLocationCardState createState() => _EventLocationCardState();
}

class _EventLocationCardState extends State<EventLocationCard> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _eventLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _geocodeAddress();
  }

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
              infoWindow: const InfoWindow(title: 'Lieu de l événement'),
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
        _errorMessage = 'Erreur de chargement de la carte.\nVeuillez configurer la clé API Google Maps.';
      });
    }
  }

  Future<void> _launchMaps() async {
    if (_eventLocation != null) {
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${_eventLocation!.latitude},${_eventLocation!.longitude}');
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d ouvrir Google Maps.')),
          );
        }
      }
    }
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
                  onPressed: _eventLocation != null ? _launchMaps : null,
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
    if (_errorMessage != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ),
      );
    }

    if (_eventLocation == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 200,
      child: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _eventLocation!,
          zoom: 15,
        ),
        markers: _markers,
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        gestureRecognizers: const {},
      ),
    );
  }
}
