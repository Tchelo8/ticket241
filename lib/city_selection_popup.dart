import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:myapp/services/api_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

/// Feuille de sélection de ville (README écran 9). Contrat public inchangé :
/// se ferme via Navigator.pop(context, cityName).
class CitySelectionPopup extends StatefulWidget {
  final String currentCity;
  const CitySelectionPopup({super.key, required this.currentCity});

  @override
  State<CitySelectionPopup> createState() => CitySelectionPopupState();
}

class CitySelectionPopupState extends State<CitySelectionPopup> {
  final ApiService _apiService = ApiService();
  Future<List<String>>? _citiesFuture;
  late String _selectedCity;

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
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.sheetTop)),
        boxShadow: context.tokens.shadows.shl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: c.line2, borderRadius: BorderRadius.circular(99)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 16, AppSpacing.screen, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VOTRE VILLE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.6, color: c.acc),
                ),
                const SizedBox(height: 4),
                Text('Où cherchez-vous ?', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                      );
                    },
                    icon: Icon(PhosphorIconsRegular.crosshair, size: 18, color: c.acc),
                    label: Text('Utiliser ma position actuelle', style: TextStyle(color: c.acc)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: FutureBuilder<List<String>>(
              future: _citiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text('Aucune ville disponible.', style: TextStyle(color: c.ink3))),
                  );
                }
                final cities = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 12),
                  itemCount: cities.length,
                  separatorBuilder: (context, __) => Container(height: 1, color: c.line),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = city == _selectedCity;
                    return _CityRow(
                      city: city,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedCity = city);
                        Navigator.pop(context, city);
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedCity),
                child: Text('Voir les événements à $_selectedCity'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityRow extends StatelessWidget {
  final String city;
  final bool isSelected;
  final VoidCallback onTap;

  const _CityRow({required this.city, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final color = isSelected ? c.acc : c.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(PhosphorIconsRegular.mapPin, size: 20, color: isSelected ? c.acc : c.ink3),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                city,
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, color: color),
              ),
            ),
            if (isSelected) Icon(PhosphorIconsFill.checkCircle, size: 24, color: c.acc),
          ],
        ),
      ),
    );
  }
}
