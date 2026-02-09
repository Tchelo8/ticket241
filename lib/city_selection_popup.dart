
import 'package:flutter/material.dart';

class CitySelectionPopup extends StatefulWidget {
  const CitySelectionPopup({super.key});

  @override
  _CitySelectionPopupState createState() => _CitySelectionPopupState();
}

class _CitySelectionPopupState extends State<CitySelectionPopup> {
  final List<String> _cities = ['Libreville', 'Owendo', 'Akanda', 'Port-Gentil', 'Franceville'];
  String _selectedCity = 'Libreville';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCities = _cities
        .where((city) => city.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    
    final themeColor = Theme.of(context).primaryColor;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA), // Light grey background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Changer de ville',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF343A40), // Darker text
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une ville',
                prefixIcon: Icon(Icons.search, color: themeColor.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    return RadioListTile<String>(
                      title: Text(city, style: TextStyle(fontWeight: _selectedCity == city ? FontWeight.bold : FontWeight.normal)),
                      value: city,
                      groupValue: _selectedCity,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value!;
                        });
                      },
                      activeColor: themeColor,
                      selected: _selectedCity == city,
                      tileColor: _selectedCity == city ? themeColor.withOpacity(0.1) : null,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedCity);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                 elevation: 5,
                 shadowColor: themeColor.withOpacity(0.4),
              ),
              child: const Text(
                'Valider',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
