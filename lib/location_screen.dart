
import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E90FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Localisation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par ville',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Use my current location
            ListTile(
              leading: const Icon(Icons.my_location, color: primaryColor),
              title: const Text(
                'Utiliser ma position actuelle',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 20),

            // Suggested cities
            Text(
              'VILLES SUGGÉRÉES',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            _buildCityRow('Port-Gentil', 'Gabon'),
            _buildCityRow('Oyem', 'Gabon'),
            _buildCityRow('Franceville', 'Gabon'),
          ],
        ),
      ),
    );
  }

  Widget _buildCityRow(String city, String country) {
    return ListTile(
      leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
      title: Text(city, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(country),
      onTap: () {},
    );
  }
}
