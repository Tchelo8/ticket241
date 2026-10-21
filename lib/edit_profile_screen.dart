import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myapp/city_selection_popup.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/app_bottom_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final ApiService _api = ApiService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';

    _fullNameController = TextEditingController(text: '$firstName $lastName'.trim());
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickCity(BuildContext context, ThemeProvider themeProvider) async {
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

  /// Prénom et nom enregistrés par l'auth-service (PUT /api/auth/me) ; l'e-mail et le numéro ne
  /// se modifient pas encore (ils servent à se connecter et à recevoir les codes).
  Future<void> _save() async {
    final words = _fullNameController.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length < 2) {
      Fluttertoast.showToast(msg: 'Indiquez votre prénom et votre nom.');
      return;
    }
    setState(() => _saving = true);
    final response = await _api.updateMyProfile(words.first, words.skip(1).join(' '));
    if (!mounted) return;
    setState(() => _saving = false);
    if (!response.success || response.data == null) {
      Fluttertoast.showToast(msg: response.messageOr("L'enregistrement a échoué, réessayez."), toastLength: Toast.LENGTH_LONG);
      return;
    }
    await context.read<AuthProvider>().updateUser({
      'firstName': response.data!['firstName'],
      'lastName': response.data!['lastName'],
    });
    if (!mounted) return;
    Fluttertoast.showToast(msg: 'Profil mis à jour.');
    context.pop();
  }

  /// Suppression du compte (logique côté serveur : rien n'est effacé, le compte passe en « supprimé »).
  /// Le mot de passe est redemandé.
  void _showDeleteConfirmation(BuildContext context) {
    // Récupérés avant les appels réseau : le contexte de l'écran n'est plus sûr après un await
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    final passwordController = TextEditingController();
    String? error;
    bool deleting = false;
    AppBottomSheet.show(
      context: context,
      kicker: 'Compte',
      title: 'Supprimer le compte',
      maxHeightFraction: 0.6,
      child: StatefulBuilder(
        builder: (sheetContext, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Vos billets déjà payés restent valables. Le compte pourra être réactivé par le support Ticket241. '
              'Confirmez avec votre mot de passe.',
              style: TextStyle(color: sheetContext.appColors.ink2, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Mot de passe'),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Color(0xFFD6006C), fontSize: 13)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Annuler'))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD6006C)),
                    onPressed: deleting
                        ? null
                        : () async {
                            if (passwordController.text.isEmpty) {
                              setSheetState(() => error = 'Le mot de passe est requis.');
                              return;
                            }
                            setSheetState(() {
                              deleting = true;
                              error = null;
                            });
                            final response = await _api.deleteMyAccount(passwordController.text);
                            if (!response.success) {
                              setSheetState(() {
                                deleting = false;
                                error = response.messageOr('La suppression a échoué, réessayez.');
                              });
                              return;
                            }
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            await auth.logout();
                            router.go('/');
                          },
                    child: Text(deleting ? 'Suppression…' : 'Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 12),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.pop(), child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink)),
                  const SizedBox(width: 14),
                  Text('Modifier le profil', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: CircleAvatar(radius: 48, backgroundColor: c.accs, child: Icon(PhosphorIconsRegular.user, size: 40, color: c.acc))),
                    const SizedBox(height: 24),
                    _field(context, controller: _fullNameController, label: 'Nom complet', icon: PhosphorIconsRegular.user),
                    const SizedBox(height: 14),
                    _field(context, controller: _phoneController, label: 'Numéro de téléphone', icon: PhosphorIconsRegular.phone, locked: true),
                    const SizedBox(height: 14),
                    _field(context, controller: _emailController, label: 'Adresse e-mail', icon: PhosphorIconsRegular.envelopeSimple, locked: true),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => _pickCity(context, themeProvider),
                      child: _staticField(context, label: 'Ville', value: themeProvider.city, icon: PhosphorIconsRegular.mapPin),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: c.line2, width: 1), borderRadius: BorderRadius.circular(AppRadii.card)),
                      child: Text(
                        "Le numéro et l'e-mail servent à vous connecter et à recevoir vos codes : pour les changer, contactez le support Ticket241.",
                        style: TextStyle(fontSize: 12.5, color: c.ink3, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Enregistrement…' : 'Enregistrer')),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD6006C))),
                        onPressed: () => _showDeleteConfirmation(context),
                        child: const Text('Supprimer le compte', style: TextStyle(color: Color(0xFFD6006C))),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context, {required TextEditingController controller, required String label, required PhosphorIconData icon, bool locked = false, TextInputType? keyboardType}) {
    final c = context.appColors;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(AppRadii.control), border: Border.all(color: c.line2, width: 1)),
      child: Row(
        children: [
          Icon(icon, size: 19, color: c.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !locked,
              keyboardType: keyboardType,
              decoration: AppFieldDecoration.bare(hintText: label),
            ),
          ),
          if (locked) Icon(PhosphorIconsRegular.lockSimple, size: 17, color: c.ink3),
        ],
      ),
    );
  }

  Widget _staticField(BuildContext context, {required String label, required String value, required PhosphorIconData icon}) {
    final c = context.appColors;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(AppRadii.control), border: Border.all(color: c.line2, width: 1)),
      child: Row(
        children: [
          Icon(icon, size: 19, color: c.ink3),
          const SizedBox(width: 10),
          Expanded(child: Text(value.isEmpty ? label : value, style: TextStyle(fontSize: 15, color: value.isEmpty ? c.ink3 : c.ink))),
          Icon(PhosphorIconsRegular.caretRight, size: 15, color: c.ink3),
        ],
      ),
    );
  }
}
