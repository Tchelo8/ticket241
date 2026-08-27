import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myapp/city_selection_popup.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/tickets_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/app_bottom_sheet.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(int)? onTabSelected;

  const ProfileScreen({super.key, this.onTabSelected});

  String _getInitials(String fullName) {
    final names = fullName.trim().split(RegExp(r'\s+'));
    String initials = '';
    if (names.isNotEmpty && names.first.isNotEmpty) {
      initials += names.first[0];
      if (names.length > 1 && names.last.isNotEmpty) initials += names.last[0];
    }
    return initials.toUpperCase();
  }

  void _showLogoutConfirmation(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      kicker: 'Compte',
      title: 'Déconnexion',
      maxHeightFraction: 0.32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Êtes-vous sûr de vouloir vous déconnecter ?', style: TextStyle(color: context.appColors.ink2)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthProvider>().logout();
                  },
                  child: const Text('Confirmer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickCity(BuildContext context) async {
    final themeProvider = context.read<ThemeProvider>();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.4,
        maxChildSize: 0.78,
        expand: false,
        builder: (context, _) => CitySelectionPopup(currentCity: themeProvider.city),
      ),
    );
    if (result != null) themeProvider.setCity(result);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final authProvider = context.watch<AuthProvider>();
    final ticketsProvider = context.watch<TicketsProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.user;
    final fullName = user != null ? '${user['firstName']} ${user['lastName']}' : 'Utilisateur';
    final phone = user?['phone']?.toString() ?? '';

    final cities = <String>{
      ...ticketsProvider.tickets.map((t) => t.location),
      ...favoritesProvider.favorites.map((e) => e.cityName),
    };

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 32),
          children: [
            Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            _buildHeader(context, fullName, phone),
            const SizedBox(height: 20),
            _buildStats(context, ticketsProvider.tickets.fold<int>(0, (s, t) => s + t.ticketCount), favoritesProvider.favorites.length, cities.length),
            const SizedBox(height: 24),
            Text('COMPTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: c.acc)),
            const SizedBox(height: 8),
            _menuCard(context, [
              _menuRow(context, PhosphorIconsRegular.ticket, 'Mes billets', '${ticketsProvider.tickets.length}', () => onTabSelected?.call(3)),
              _menuRow(context, PhosphorIconsRegular.heart, 'Favoris', '${favoritesProvider.favorites.length}', () => onTabSelected?.call(2)),
              _menuRow(context, PhosphorIconsRegular.creditCard, 'Moyens de paiement', '', () {}),
              _menuRow(context, PhosphorIconsRegular.mapPin, 'Ville par défaut', themeProvider.city, () => _pickCity(context)),
            ]),
            const SizedBox(height: 24),
            Text('PRÉFÉRENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: c.acc)),
            const SizedBox(height: 8),
            _menuCard(context, [
              _appearanceRow(context, themeProvider),
              _menuRow(context, PhosphorIconsRegular.bell, 'Notifications', '', () => context.push('/notifications')),
              _menuRow(context, PhosphorIconsRegular.question, 'Centre d\'aide', '', () {}),
              _menuRow(context, PhosphorIconsRegular.fileText, 'Conditions de vente', '', () {}),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutConfirmation(context),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD6006C), width: 1)),
                icon: const Icon(PhosphorIconsRegular.signOut, size: 18, color: Color(0xFFD6006C)),
                label: const Text('Déconnexion', style: TextStyle(color: Color(0xFFD6006C))),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text('Ticket241 · version 2.0.0', style: TextStyle(fontSize: 11.5, color: c.ink3))),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String fullName, String phone) {
    final c = context.appColors;
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: c.accs,
          child: Text(_getInitials(fullName), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: c.acc)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: c.ink)),
              const SizedBox(height: 2),
              Text(phone, style: TextStyle(fontSize: 13, color: c.ink3, fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/edit-profile'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.card, shape: BoxShape.circle, border: Border.all(color: c.line, width: 1)),
            child: Icon(PhosphorIconsRegular.pencilSimple, size: 17, color: c.ink),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, int tickets, int favorites, int cities) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: c.line, width: 1))),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: _statColumn(context, '$tickets', 'BILLETS')),
          Container(width: 1, height: 32, color: c.line),
          Expanded(child: _statColumn(context, '$favorites', 'FAVORIS')),
          Container(width: 1, height: 32, color: c.line),
          Expanded(child: _statColumn(context, '$cities', 'VILLES')),
        ],
      ),
    );
  }

  Widget _statColumn(BuildContext context, String value, String label) {
    final c = context.appColors;
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: c.ink)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, letterSpacing: 1, color: c.ink3)),
      ],
    );
  }

  Widget _menuCard(BuildContext context, List<Widget> rows) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: c.line, width: 1)),
      child: Column(children: rows),
    );
  }

  Widget _menuRow(BuildContext context, PhosphorIconData icon, String label, String value, VoidCallback onTap) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 21, color: c.acc),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontSize: 15.5, color: c.ink))),
            if (value.isNotEmpty) Text(value, style: TextStyle(fontSize: 13, color: c.ink3)),
            const SizedBox(width: 6),
            Icon(PhosphorIconsRegular.caretRight, size: 15, color: c.ink3),
          ],
        ),
      ),
    );
  }

  Widget _appearanceRow(BuildContext context, ThemeProvider themeProvider) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.paintBrush, size: 21, color: c.acc),
          const SizedBox(width: 14),
          Expanded(child: Text('Apparence', style: TextStyle(fontSize: 15.5, color: c.ink))),
          _themePill(context, 'Papier', AppThemeVariant.paper, themeProvider),
          const SizedBox(width: 6),
          _themePill(context, 'Encre', AppThemeVariant.ink, themeProvider),
          const SizedBox(width: 6),
          _themePill(context, 'N&B', AppThemeVariant.mono, themeProvider),
        ],
      ),
    );
  }

  Widget _themePill(BuildContext context, String label, AppThemeVariant variant, ThemeProvider themeProvider) {
    final c = context.appColors;
    final active = themeProvider.variant == variant;
    return GestureDetector(
      onTap: () => themeProvider.setVariant(variant),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? c.ink : c.surf,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? c.bg : c.ink2)),
      ),
    );
  }
}
