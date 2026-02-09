
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(int)? onTabSelected;

  const ProfileScreen({super.key, this.onTabSelected});

  // Function to show the logout confirmation sheet
  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Déconnexion',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context), // Dismiss the sheet
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler', style: TextStyle(fontSize: 16, color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirmer', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

   // Helper function to get initials from a full name
  String _getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0];
      if (names.length > 1) {
        initials += names[names.length - 1][0]; // First letter of first and last name
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(),
          const SizedBox(height: 30),
          _buildProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Modifier le Profil',
            onTap: () {
              context.push('/edit-profile');
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.local_activity_outlined,
            title: 'Mes Billets',
            onTap: () {
              onTabSelected?.call(3); // 3 is the index for Tickets
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Adresses',
            onTap: () {
              context.push('/location');
            },
          ),
           _buildProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Paiements',
            onTap: () {},
          ),
          const Divider(height: 40, thickness: 1, indent: 10, endIndent: 10),
          _buildProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Centre d\'aide',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            onTap: () => _showLogoutConfirmation(context),
            textColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  // Widget for the profile header
  Widget _buildProfileHeader() {
    const String fullName = 'Henoc Bessa';
    final String initials = _getInitials(fullName);

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF1E90FF).withAlpha((255 * 0.15).round()),
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E90FF),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          fullName,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Widget for a single menu item
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    );
  }
}
