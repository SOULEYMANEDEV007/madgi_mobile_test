// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:madgi_mobile/password.dart';
import 'package:madgi_mobile/inscription.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController usernameTextEditingController = TextEditingController();
  final TextEditingController motdepasseTextEditingController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/attention.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 10),
            const Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 10),
            const Text('Succès'),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _login() async {
    final username = usernameTextEditingController.text.trim();
    final password = motdepasseTextEditingController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Veuillez saisir tous les champs, s\'il vous plaît.');
      return;
    }

    // Validation basique de l'email
    if (!username.contains('@') || !username.contains('.')) {
      _showErrorDialog('Veuillez saisir une adresse email valide.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.01.9:8000/api/v1/connexion');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          "email": username,
          "password": password
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decode = json.decode(response.body);

        if (decode['code'] == 200) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final mapBody = json.encode({
            'user': decode['data']['user'],
            'token': decode['data']['token'],
          });
          await prefs.setString('userInfo', mapBody);

          // Sauvegarder les identifiants si "Se souvenir de moi" est coché
          if (_rememberMe) {
            await prefs.setString('saved_email', username);
            await prefs.setString('saved_password', password);
            await prefs.setBool('remember_me', true);
          } else {
            await prefs.remove('saved_email');
            await prefs.remove('saved_password');
            await prefs.remove('remember_me');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Accueil(),
            ),
          );
        } else {
          _showErrorDialog(decode['message'] ?? 'Erreur lors de la connexion');
        }
      } else {
        _showErrorDialog('Erreur serveur (${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      _showErrorDialog('Erreur réseau: ${e.message}');
    } on TimeoutException {
      _showErrorDialog('La connexion a expiré. Vérifiez votre réseau.');
    } on FormatException {
      _showErrorDialog('Réponse serveur invalide.');
    } catch (e) {
      _showErrorDialog('Une erreur est survenue: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      final savedEmail = prefs.getString('saved_email') ?? '';
      final savedPassword = prefs.getString('saved_password') ?? '';

      setState(() {
        usernameTextEditingController.text = savedEmail;
        motdepasseTextEditingController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvoked: (value) => null,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'CONNEXION',
                style: TextStyle(
                  color: Color(0xFF0F0F0F),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/pana.png',
                width: 122.97,
                height: 122.65,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey);
                },
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildTextField('E-mail', 'exemple@email.com', isPassword: false),
                    const SizedBox(height: 20),
                    _buildTextField('Mot de passe', 'Saisissez votre mot de passe', isPassword: true),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Se souvenir de moi',
                              style: TextStyle(
                                color: Color(0xFF0F0F0F),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Password()),
                            );
                          },
                          child: const Text(
                            'Mot de passe oublié?',
                            style: TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                      onTap: _isLoading ? null : _login,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? Colors.grey
                              : const Color(0xFF406ACC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _isLoading ? 'Connexion...' : 'Se connecter',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Pas de compte? ',
                            style: TextStyle(color: Color(0xFF0F0F0F)),
                          ),
                          TextSpan(
                            text: 'Créer un compte',
                            style: const TextStyle(
                              color: Color(0xFF7F9BDD),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Inscription()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F0F0F),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: isPassword ? motdepasseTextEditingController : usernameTextEditingController,
          obscureText: isPassword && _obscureText,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3F3F3F)),
            filled: true,
            fillColor: const Color(0xFFFAF7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: _isLoading ? null : _togglePasswordVisibility,
            )
                : null,
          ),
          style: const TextStyle(color: Colors.black),
          keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
        ),
      ],
    );
  }
}