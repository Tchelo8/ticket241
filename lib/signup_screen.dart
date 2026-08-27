import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, String> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    for (final c in [_firstNameController, _lastNameController, _emailController, _phoneController, _passwordController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  int get _passwordScore {
    final p = _passwordController.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]')) || p.contains(RegExp(r'[^a-zA-Z0-9]'))) score++;
    return score;
  }

  bool get _formValid =>
      _firstNameController.text.isNotEmpty &&
      _lastNameController.text.isNotEmpty &&
      _emailController.text.contains('@') &&
      _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').length >= 8 &&
      _passwordController.text.length >= 8 &&
      _agreedToTerms;

  Future<void> _submitForm() async {
    if (!_formValid || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _validationErrors = {};
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        context.go('/otp-verification', extra: {'phone': _phoneController.text});
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        setState(() => _validationErrors = Map<String, String>.from(e));
      } else {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenForm, 8, AppSpacing.screenForm, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(onTap: () => context.go('/'), child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink)),
                  Image.asset('assets/images/logo.png', height: 34),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INSCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.6, color: c.acc)),
                    const SizedBox(height: 6),
                    Text('Créons votre compte.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _field(controller: _firstNameController, hint: 'Prénom', errorText: _validationErrors['firstName'])),
                        const SizedBox(width: 11),
                        Expanded(child: _field(controller: _lastNameController, hint: 'Nom', errorText: _validationErrors['lastName'])),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _field(controller: _emailController, hint: 'Adresse e-mail', icon: PhosphorIconsRegular.envelopeSimple, keyboardType: TextInputType.emailAddress, errorText: _validationErrors['email']),
                    const SizedBox(height: 14),
                    _field(controller: _phoneController, hint: 'Numéro de téléphone', icon: PhosphorIconsRegular.phone, keyboardType: TextInputType.phone, prefix: '+241 ', errorText: _validationErrors['phone']),
                    const SizedBox(height: 6),
                    Text('Ce numéro recevra vos billets et vos demandes de paiement.', style: TextStyle(fontSize: 12, color: c.ink3)),
                    const SizedBox(height: 14),
                    _field(
                      controller: _passwordController,
                      hint: 'Mot de passe',
                      icon: PhosphorIconsRegular.lockKey,
                      obscure: !_isPasswordVisible,
                      errorText: _validationErrors['password'],
                      suffix: GestureDetector(
                        onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        child: Icon(_isPasswordVisible ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye, size: 19, color: c.ink3),
                      ),
                    ),
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _passwordStrength(context),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: _agreedToTerms ? c.acc : Colors.transparent,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: _agreedToTerms ? c.acc : c.line2, width: 1.5),
                            ),
                            child: _agreedToTerms ? const Icon(PhosphorIconsBold.check, size: 15, color: Colors.white) : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'J\'accepte les ',
                              style: TextStyle(fontSize: 13, color: c.ink2),
                              children: [
                                TextSpan(text: 'Conditions d\'utilisation', style: TextStyle(color: c.acc)),
                                const TextSpan(text: ' et la '),
                                TextSpan(text: 'Politique de confidentialité', style: TextStyle(color: c.acc)),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(_errorMessage!, style: const TextStyle(color: Color(0xFFD6006C), fontSize: 13), textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenForm, 12, AppSpacing.screenForm, 16),
              decoration: BoxDecoration(color: c.glass, border: Border(top: BorderSide(color: c.line, width: 1))),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_formValid && !_isLoading) ? _submitForm : null,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                            : const Text('Créer mon compte'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Déjà un compte ? ', style: TextStyle(fontSize: 13, color: c.ink2)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text('Se connecter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.acc)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordStrength(BuildContext context) {
    final c = context.appColors;
    final score = _passwordScore;
    final labels = ['', 'Trop faible', 'Correct', 'Solide'];
    final colors = [c.line2, const Color(0xFFD6006C), c.ink2, c.acc];
    final widths = [0.0, 0.33, 0.67, 1.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            height: 3,
            color: c.line,
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0, end: widths[score]),
              builder: (context, value, _) => FractionallySizedBox(
                widthFactor: value,
                child: Container(height: 3, color: colors[score]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors[score]),
          child: Text(labels[score]),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    PhosphorIconData? icon,
    String? prefix,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    String? errorText,
  }) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadii.control),
            border: Border.all(color: errorText != null ? const Color(0xFFD6006C) : c.line2, width: 1),
          ),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: c.ink3), const SizedBox(width: 10)],
              if (prefix != null) Text(prefix, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink2)),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  decoration: AppFieldDecoration.bare(hintText: hint),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(errorText, style: const TextStyle(color: Color(0xFFD6006C), fontSize: 11.5)),
          ),
      ],
    );
  }
}
