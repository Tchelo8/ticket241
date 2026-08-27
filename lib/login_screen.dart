import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _phoneController.text,
        _passwordController.text,
      );
      Fluttertoast.showToast(
        msg: 'Connexion réussie !',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final blocks = [
      Image.asset('assets/images/logo.png', height: 118),
      const SizedBox(height: 24),
      Text('CONNEXION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.6, color: c.acc)),
      const SizedBox(height: 6),
      Text('Bonsoir.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 38)),
      const SizedBox(height: 6),
      Text('Votre numéro et votre mot de passe suffisent.', style: TextStyle(fontSize: 15, color: c.ink2)),
      const SizedBox(height: 32),
      _phoneField(context),
      const SizedBox(height: 14),
      _passwordField(context),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: Text('Mot de passe oublié ?', style: TextStyle(fontSize: 13, color: c.acc)),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitLogin,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
              : const Text('Se connecter'),
        ),
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Expanded(child: Container(height: 1, color: c.line)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OU', style: TextStyle(fontSize: 12, color: c.ink3))),
          Expanded(child: Container(height: 1, color: c.line)),
        ],
      ),
      const SizedBox(height: 18),
      SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => context.push('/signup'),
          icon: Icon(PhosphorIconsRegular.userPlus, size: 18, color: c.ink),
          label: const Text('S\'inscrire'),
        ),
      ),
      const SizedBox(height: 20),
      Text.rich(
        TextSpan(
          text: 'En continuant, vous acceptez nos ',
          style: TextStyle(fontSize: 12.5, color: c.ink3),
          children: [
            TextSpan(text: 'Conditions d\'utilisation', style: TextStyle(color: c.acc)),
            const TextSpan(text: ' et notre '),
            TextSpan(text: 'Politique de confidentialité', style: TextStyle(color: c.acc)),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm, vertical: 24),
            child: Form(
              key: _formKey,
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: AppMotion.tRise,
                    delay: AppMotion.staggerStep,
                    childAnimationBuilder: (widget) => SlideAnimation(verticalOffset: 26, child: FadeInAnimation(child: widget)),
                    children: blocks,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneField(BuildContext context) {
    final c = context.appColors;
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: c.line2, width: 1),
        boxShadow: context.tokens.shadows.sh,
      ),
      child: Row(
        children: [
          Text('+241', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: c.ink2)),
          const SizedBox(width: 10),
          Container(width: 1, height: 24, color: c.line2),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontFeatures: const [FontFeature.tabularFigures()]),
              decoration: AppFieldDecoration.bare(hintText: '074 12 34 56'),
              validator: (value) => (value == null || value.isEmpty) ? 'Numéro requis' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    final c = context.appColors;
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: c.line2, width: 1),
        boxShadow: context.tokens.shadows.sh,
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.lockKey, size: 19, color: c.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: AppFieldDecoration.bare(hintText: 'Mot de passe'),
              validator: (value) => (value == null || value.isEmpty) ? 'Mot de passe requis' : null,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            child: Icon(_isPasswordVisible ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye, size: 19, color: c.ink3),
          ),
        ],
      ),
    );
  }
}
