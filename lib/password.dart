import 'package:flutter/material.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isLoading = false;
  bool _isVisible = false;
  bool _isEmailSent = false;
  bool _showEmailField = true;
  bool _showPasswordFields = false;

  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  final TextEditingController confirmPasswordTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

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
            // Icône de sécurité
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset,
                color: primaryColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showEmailField ? 'Mot de passe oublié' : 'Nouveau mot de passe',
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showEmailField
                  ? 'Entrez votre email pour réinitialiser votre mot de passe'
                  : 'Créez un nouveau mot de passe sécurisé',
              textAlign: TextAlign.center,
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
    bool enabled = true,
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
                obscureText: isPassword ? _isPasswordObscure : (isConfirmPassword ? _isConfirmPasswordObscure : false),
                enabled: enabled && !_isLoading,
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
                    borderSide: BorderSide(color: errorColor, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: (isPassword || isConfirmPassword)
                      ? IconButton(
                    icon: Icon(
                      isPassword
                          ? (_isPasswordObscure ? Icons.visibility_off : Icons.visibility)
                          : (_isConfirmPasswordObscure ? Icons.visibility_off : Icons.visibility),
                      color: mediumGray,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                      setState(() {
                        if (isPassword) {
                          _isPasswordObscure = !_isPasswordObscure;
                        } else {
                          _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
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

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            label: 'Adresse email',
            controller: emailTextEditingController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 24),

          // Bouton d'envoi
          _buildActionButton(
            text: 'Envoyer le lien de réinitialisation',
            onPressed: _handleSendResetLink,
          ),

          const SizedBox(height: 16),

          // Lien retour connexion
          _buildBackToLoginLink(),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          _buildTextField(
            label: 'Nouveau mot de passe',
            controller: passwordTextEditingController,
            isPassword: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Confirmer le mot de passe',
            controller: confirmPasswordTextEditingController,
            isConfirmPassword: true,
            validator: _validateConfirmPassword,
          ),

          // Indicateurs de force du mot de passe
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le mot de passe doit contenir :',
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                _buildPasswordRequirement('Au moins 8 caractères', true),
                _buildPasswordRequirement('Une lettre majuscule', false),
                _buildPasswordRequirement('Un chiffre', false),
                _buildPasswordRequirement('Un caractère spécial', false),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton de réinitialisation
          _buildActionButton(
            text: 'Réinitialiser le mot de passe',
            onPressed: _handleResetPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle,
            color: isValid ? successColor : mediumGray,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isValid ? successColor : textColor.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback onPressed}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
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
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () {
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back,
              color: primaryColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Retour à la connexion',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1 : 0,
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: successColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: successColor,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'Email envoyé !',
              style: TextStyle(
                color: successColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre boîte de réception pour le lien de réinitialisation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEmailSent = true;
                  _showEmailField = false;
                  _showPasswordFields = true;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: successColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continuer',
                style: TextStyle(
                  color: successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != passwordTextEditingController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  void _handleSendResetLink() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulation d'envoi d'email
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _isEmailSent = true;
        });
      });
    }
  }

  void _handleResetPassword() {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulation de réinitialisation
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
                  color: successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: successColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mot de passe réinitialisé',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre mot de passe a été mis à jour avec succès.',
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
                    Navigator.of(context).pop(); // Retour à la connexion
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

                // Formulaire
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(top: 20),
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
                      if (_showEmailField && !_isEmailSent)
                        _buildEmailForm(),

                      if (_isEmailSent && _showEmailField)
                        _buildSuccessMessage(),

                      if (_showPasswordFields)
                        _buildPasswordForm(),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}