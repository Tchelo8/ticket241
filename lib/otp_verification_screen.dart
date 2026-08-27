import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

/// README écran 5 spécifie 4 cases ; le backend (AuthProvider.verifyOtp)
/// attend un code à 6 chiffres (validation d'origine). Le nombre de cases
/// est adapté à 6 pour rester fonctionnel avec l'API réelle — c'est
/// l'un des rares écarts assumés au prototype, documenté ici.
const _codeLength = 6;

class OtpVerificationScreen extends StatefulWidget {
  final String? phone;

  const OtpVerificationScreen({super.key, this.phone});

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _code = '';
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _timer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_code.length >= _codeLength || _isLoading) return;
    setState(() {
      _code += digit;
      _errorMessage = null;
    });
    if (_code.length == _codeLength) {
      Future.delayed(const Duration(milliseconds: 340), _verifyOtp);
    }
  }

  void _onBackspace() {
    if (_code.isEmpty) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  void _clear() => setState(() => _code = '');

  Future<void> _verifyOtp() async {
    if (widget.phone == null) {
      setState(() => _errorMessage = 'Numéro de téléphone manquant.');
      return;
    }
    if (_code.length != _codeLength) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).verifyOtp(widget.phone!, _code);
      if (mounted) context.go('/app');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _code = '';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (widget.phone == null || _secondsLeft > 0) return;
    try {
      await Provider.of<AuthProvider>(context, listen: false).resendOtp(widget.phone!);
      _startTimer();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenForm, 8, AppSpacing.screenForm, 0),
              child: GestureDetector(onTap: () => context.go('/signup'), child: Icon(PhosphorIconsRegular.arrowLeft, color: c.ink)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Le code, s\'il vous plaît.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34)),
                    const SizedBox(height: 8),
                    Text(
                      widget.phone != null ? 'Envoyé au +241 ${widget.phone}.' : 'Code de vérification.',
                      style: TextStyle(fontSize: 15, color: c.ink2),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: List.generate(_codeLength, (i) {
                        final filled = i < _code.length;
                        final active = i == _code.length;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < _codeLength - 1 ? 8 : 0),
                            height: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.card,
                              borderRadius: BorderRadius.circular(AppRadii.control),
                              border: Border.all(color: active ? c.acc : c.line2, width: active ? 1.5 : 1),
                            ),
                            child: Text(
                              filled ? _code[i] : '',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: c.ink, fontFeatures: const [FontFeature.tabularFigures()]),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(_errorMessage!, style: const TextStyle(color: Color(0xFFD6006C), fontSize: 13), textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _secondsLeft > 0 ? 'Renvoyer dans 0:${_secondsLeft.toString().padLeft(2, '0')}' : 'Vous pouvez renvoyer le code',
                          style: TextStyle(fontSize: 12.5, color: c.ink3),
                        ),
                        GestureDetector(
                          onTap: _secondsLeft == 0 ? _resendOtp : null,
                          child: Text('Renvoyer', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _secondsLeft == 0 ? c.acc : c.ink3)),
                        ),
                        GestureDetector(
                          onTap: _clear,
                          child: Text('Effacer', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.acc)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading) Center(child: Padding(padding: const EdgeInsets.all(16), child: CircularProgressIndicator(color: c.acc))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenForm, 0, AppSpacing.screenForm, 16),
              child: _Keypad(onDigit: _onDigit, onBackspace: _onBackspace),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  const _Keypad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: key.isEmpty
                      ? const SizedBox(height: 56)
                      : _KeypadButton(
                          label: key,
                          onTap: key == '⌫' ? onBackspace : () => onDigit(key),
                        ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _KeypadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: c.line, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: c.ink)),
      ),
    );
  }
}
