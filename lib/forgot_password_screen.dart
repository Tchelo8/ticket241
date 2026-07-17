
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForgotPassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // This will call the backend and get a response
    final apiResponse = await authProvider.forgotPassword(_phoneController.text);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show the message from the backend (success or error)
      Fluttertoast.showToast(
        msg: apiResponse.message ?? apiResponse.error ?? "Une erreur est survenue.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: apiResponse.success ? Colors.green : Colors.red,
        textColor: Colors.white,
      );

      // Navigate back to login screen on success
      if (apiResponse.success) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Lottie.asset(
                    'assets/animations/password.json', // Using the correct animation
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mot de passe oublié',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entrez votre numéro de téléphone pour recevoir les instructions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForgotPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1E90FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: const Color(0xFF1E90FF).withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Envoyer',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
