import 'dart:async';

import 'package:flutter/material.dart';

class Validation extends StatefulWidget {
  const Validation({super.key});

  @override
  State<Validation> createState() => _ValidationState();
}

class _ValidationState extends State<Validation> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);

  double _scale = 0.0;
  double _opacity = 0.0;
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    // Animation d'entrée
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
          _opacity = 1.0;
        });
      }
    });

    // Auto-navigation après 5 secondes
    _autoNavigateTimer = Timer(const Duration(seconds: 5), () {
      _navigateToHome();
    });
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor.withOpacity(0.95),
            backgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Éléments décoratifs
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: secondaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: secondaryColor.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cercle animé
            AnimatedContainer(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: secondaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),

            // Icône de succès
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: secondaryColor,
                  size: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  '✓',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          Text(
            'Demande validée',
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Votre demande a été envoyée avec succès et est en cours de traitement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 800),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Prochaines étapes',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStepItem(
              Icons.notifications,
              'Notification',
              'Vous recevrez une notification lorsque votre demande sera traitée.',
            ),
            const SizedBox(height: 12),
            _buildStepItem(
              Icons.history,
              'Suivi',
              'Consultez l\'historique pour suivre l\'avancement de votre demande.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _navigateToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              child: Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Redirection automatique dans 5 secondes...',
            style: TextStyle(
              color: textColor.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/conger');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: primaryColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.list_alt,
                  color: primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Voir mes demandes',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    if (_autoNavigateTimer?.isActive ?? false) {
      _autoNavigateTimer!.cancel();
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildSuccessAnimation(),
                  const SizedBox(height: 40),
                  _buildMessage(),
                  const SizedBox(height: 32),
                  _buildNextSteps(),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}