
import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E90FF);
    const backgroundColor = Colors.white;
    const cardColor = Color(0xFFF3F4F6); // A light grey for cards
    const textColor = Colors.black87;
    const subtextColor = Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Location',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Search Bar
            TextField(
              style: const TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search by city',
                hintStyle: const TextStyle(color: subtextColor),
                prefixIcon: const Icon(Icons.search, color: subtextColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 30),

            // Use my current location
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.my_location, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Use my current location',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Suggested cities
            const Text(
              'SUGGESTED CITIES',
              style: TextStyle(
                color: subtextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14, // Adjusted for light theme
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCityRow('Libreville', 'Gabon', cardColor, textColor, subtextColor),
                  _buildCityRow('Port-Gentil', 'Gabon', cardColor, textColor, subtextColor),
                  _buildCityRow('Oyem', 'Gabon', cardColor, textColor, subtextColor),
                  _buildCityRow('Franceville', 'Gabon', cardColor, textColor, subtextColor),
                  _buildCityRow('Lambaréné', 'Gabon', cardColor, textColor, subtextColor),
                  _buildCityRow('Bitam', 'Gabon', cardColor, textColor, subtextColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityRow(String city, String country, Color cardColor, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_outlined, color: Colors.black54, size: 24),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
                const SizedBox(height: 4),
                Text(country, style: TextStyle(color: subtextColor, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
