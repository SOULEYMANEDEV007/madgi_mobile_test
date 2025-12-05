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
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);

  final TextEditingController usernameTextEditingController = TextEditingController();
  final TextEditingController motdepasseTextEditingController = TextEditingController();

  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: errorColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final username = usernameTextEditingController.text.trim();
    final password = motdepasseTextEditingController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Veuillez saisir tous les champs');
      return;
    }

    // Validation basique de l'email
    if (!username.contains('@') || !username.contains('.')) {
      _showErrorDialog('Veuillez saisir une adresse email valide');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.01.12:8000/api/v1/connexion');

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

          // Animation de succès avant navigation
          setState(() => _isLoading = false);
          _showSuccessAnimation();

          // Navigation après un délai
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Accueil(),
              ),
            );
          });
        } else {
          _showErrorDialog(decode['message'] ?? 'Erreur lors de la connexion');
          setState(() => _isLoading = false);
        }
      } else {
        _showErrorDialog('Erreur serveur (${response.statusCode})');
        setState(() => _isLoading = false);
      }
    } on http.ClientException catch (e) {
      _showErrorDialog('Erreur réseau: ${e.message}');
      setState(() => _isLoading = false);
    } on TimeoutException {
      _showErrorDialog('La connexion a expiré. Vérifiez votre réseau');
      setState(() => _isLoading = false);
    } on FormatException {
      _showErrorDialog('Réponse serveur invalide');
      setState(() => _isLoading = false);
    } catch (e) {
      _showErrorDialog('Une erreur est survenue: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle,
              color: successColor,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    // Animation d'apparition progressive
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _isVisible = true);
    });
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _isVisible ? 1 : 0,
        curve: Curves.easeInOut,
        child: Column(
          children: [
            // Logo ou icône
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_scanner,
                color: primaryColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MADGI',
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connexion à votre espace',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isPassword = false}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: isPassword ? motdepasseTextEditingController : usernameTextEditingController,
                obscureText: isPassword && _obscureText,
                enabled: !_isLoading,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: hint,
                  hintStyle: TextStyle(color: mediumGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: mediumGray, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: mediumGray, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: isPassword
                      ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: mediumGray,
                    ),
                    onPressed: _isLoading ? null : _togglePasswordVisibility,
                  )
                      : null,
                ),
                keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: primaryColor.withOpacity(0.3),
            ),
            child: _isLoading
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Se connecter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: _isLoading
                      ? null
                      : (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return primaryColor;
                    }
                    return Colors.transparent;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'Se souvenir de moi',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Password()),
                );
              },
              child: Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(top: 32),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
            ),
            children: [
              const TextSpan(
                text: 'Pas de compte ? ',
              ),
              TextSpan(
                text: 'Créer un compte',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = _isLoading
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Inscription()),
                    );
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildHeader(),

                // Formulaire de connexion
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField('Adresse email', 'exemple@email.com', isPassword: false),
                      const SizedBox(height: 16),
                      _buildTextField('Mot de passe', 'Saisissez votre mot de passe', isPassword: true),

                      _buildOptionsRow(),

                      _buildLoginButton(),
                    ],
                  ),
                ),

                _buildRegisterLink(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}