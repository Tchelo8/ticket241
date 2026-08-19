
import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart';

class CitySelectionPopup extends StatefulWidget {
  final String currentCity;
  const CitySelectionPopup({super.key, required this.currentCity});

  @override
  _CitySelectionPopupState createState() => _CitySelectionPopupState();
}

class _CitySelectionPopupState extends State<CitySelectionPopup> {
  final ApiService _apiService = ApiService();
  Future<List<String>>? _citiesFuture;
  late String _selectedCity;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.currentCity;
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
                    hintText: 'Rechercher une ville...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeColor),
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
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Aucune ville disponible.'));
                      }

                      final cities = snapshot.data!
                          .where((city) => city.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .toList();

                      return ListView.builder(
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          final isSelected = city == _selectedCity;
                          return ListTile(
                            title: Text(
                              city,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? themeColor : Colors.black87,
                              ),
                            ),
                            trailing: isSelected ? Icon(Icons.check_circle, color: themeColor) : null,
                            onTap: () {
                              // Met à jour l'état local pour le visuel
                              setState(() {
                                _selectedCity = city;
                              });
                              // Ferme le popup et retourne la ville sélectionnée
                              Navigator.pop(context, city);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
