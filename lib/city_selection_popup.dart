
import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart';

class CitySelectionPopup extends StatefulWidget {
  const CitySelectionPopup({super.key});

  @override
  _CitySelectionPopupState createState() => _CitySelectionPopupState();
}

class _CitySelectionPopupState extends State<CitySelectionPopup> {
  final ApiService _apiService = ApiService();
  Future<List<String>>? _citiesFuture;
  String _selectedCity = 'Libreville';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _citiesFuture = _fetchCities();
  }

  Future<List<String>> _fetchCities() async {
    final response = await _apiService.getActiveCities();
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      // Gérer l'erreur, peut-être afficher un message à l'utilisateur
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: FutureBuilder<List<String>>(
                future: _citiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Erreur de chargement des villes'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune ville trouvée'));
                  } else {
                    final cities = snapshot.data!;
                    final filteredCities = cities
                        .where((city) => city.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();

                    return ClipRRect(
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
                    );
                  }
                },
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
