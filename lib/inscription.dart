import 'package:flutter/material.dart';
import 'package:madgi_mobile/password.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);

  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;
  bool _isVisible = false;

  final TextEditingController motdepasseTextEditingController = TextEditingController();
  final TextEditingController confirmMotdepasseTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController nomTextEditingController = TextEditingController();
  final TextEditingController prenomTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Animation d'apparition progressive
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _isVisible = true);
    });
  }

  Widget _buildHeader() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1,
                color: primaryColor,
                size: 50,
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
              'Création de votre compte',
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
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
              child: TextFormField(
                controller: controller,
                obscureText: isPassword ? _isObscure : (isConfirmPassword ? _isConfirmObscure : false),
                enabled: !_isLoading,
                style: TextStyle(color: textColor),
                keyboardType: keyboardType,
                validator: validator,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Saisissez votre $label',
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE53E3E), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: (isPassword || isConfirmPassword)
                      ? IconButton(
                    icon: Icon(
                      isPassword
                          ? (_isObscure ? Icons.visibility_off : Icons.visibility)
                          : (_isConfirmObscure ? Icons.visibility_off : Icons.visibility),
                      color: mediumGray,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                      setState(() {
                        if (isPassword) {
                          _isObscure = !_isObscure;
                        } else {
                          _isConfirmObscure = !_isConfirmObscure;
                        }
                      });
                    },
                  )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(top: 32),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
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
              "S'inscrire",
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

  Widget _buildForgotPasswordLink() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        child: GestureDetector(
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
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez saisir un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != motdepasseTextEditingController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Le $fieldName est requis';
    }
    return null;
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simuler l'inscription
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  color: secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: secondaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Inscription réussie',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre compte a été créé avec succès. Vous pouvez maintenant vous connecter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(); // Retour à la page de connexion
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildHeader(),

                // Formulaire d'inscription
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Nom d\'utilisateur',
                          controller: nomTextEditingController,
                          validator: (value) => _validateRequired(value, 'nom d\'utilisateur'),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Adresse email',
                          controller: emailTextEditingController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Mot de passe',
                          controller: motdepasseTextEditingController,
                          isPassword: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Confirmer le mot de passe',
                          controller: confirmMotdepasseTextEditingController,
                          isConfirmPassword: true,
                          validator: _validateConfirmPassword,
                        ),

                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ),

                _buildForgotPasswordLink(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}