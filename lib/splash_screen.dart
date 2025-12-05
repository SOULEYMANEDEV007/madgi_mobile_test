import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BlocAcceuil/acceuil.dart';
import 'connexion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);

  double _logoScale = 0.0;
  double _opacity = 0.0;
  double _textOffset = 20.0;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _checkUserSession();
  }

  void _startAnimations() {
    // Animation d'entrée du logo
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _logoScale = 1.0;
        });
      }
    });

    // Animation du texte
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _textOffset = 0.0;
        });
      }
    });

    // Marquage comme terminé
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _animationComplete = true;
        });
      }
    });
  }

  Future<void> _checkUserSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mounted) {
      if (prefs.containsKey('userInfo')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Accueil(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Connexion(),
          ),
        );
      }
    }
  }

  Widget _buildLogo() {
    return AnimatedScale(
      scale: _logoScale,
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cercle extérieur animé
            _animationComplete
                ? Container()
                : AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),

            // Logo
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: primaryColor,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'MADGI',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText() {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 800),
      child: AnimatedSlide(
        offset: Offset(0, _textOffset),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        child: Column(
          children: [
            Text(
              'Administration Publique',
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre espace en un clic',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          minHeight: 4,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    );
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
                color: primaryColor.withOpacity(0.05),
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
                color: secondaryColor.withOpacity(0.05),
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildText(),
                const SizedBox(height: 60),
                _buildProgressIndicator(),
              ],
            ),
          ),

          // Version en bas
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 MADGI',
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _buildBackground(),
      ),
    );
  }
}