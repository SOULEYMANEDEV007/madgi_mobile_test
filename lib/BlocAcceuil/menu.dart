import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/conger.dart';
import 'package:madgi_mobile/BlocAcceuil/profilscreen.dart';
import 'package:madgi_mobile/BlocAcceuil/scane.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Acceuil.dart';
import 'acceuil.dart';
import 'package:http/http.dart' as http;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  // Utilisation des mêmes couleurs que l'accueil
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);

  Future<void> _logout() async {
    final result = await showDialog(
      context: context,
      builder: (context) => _buildLogoutDialog(),
    );

    if (result == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userInfoString = prefs.getString('userInfo');

        if (userInfoString != null) {
          final userData = json.decode(userInfoString);
          final token = userData['token'];

          var headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          };

          var request = http.Request('POST', Uri.parse('http://192.168.1.12:8000/api/v1/connexion'));
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            await prefs.clear();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/connecter',
                    (route) => false,
              );
            }
          } else {
            if (mounted) {
              _showErrorSnackBar('Erreur lors de la déconnexion');
            }
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Erreur de connexion');
        }
      }
    }
  }

  Widget _buildLogoutDialog() {
    return Dialog(
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
            Icon(
              Icons.logout,
              color: primaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Déconnexion',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Voulez-vous vraiment vous déconnecter ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: mediumGray),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Material(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : mediumGray,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : textColor.withOpacity(0.7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.chevron_right,
                    color: primaryColor,
                    size: 24,
                  ),
              ],
            ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage("assets/images.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MADGI",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Administration Publique",
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: textColor.withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Section navigation
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, bottom: 8),
              child: Text(
                "Navigation",
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.home_outlined,
                      title: 'Accueil',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Accueil(),
                          ),
                        );
                      },
                      isSelected: true,
                    ),

                    _buildMenuItem(
                      icon: Icons.qr_code_scanner,
                      title: 'Emargement',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Acceuil(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.event_note,
                      title: 'Congés & Absences',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Conger(back: true),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Séparateur
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(
                        color: mediumGray,
                        thickness: 1,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 24, left: 24, bottom: 8),
                      child: Text(
                        "Mon compte",
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Profil',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(back: true),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bouton de déconnexion
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: mediumGray),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.power_settings_new,
                            color: Color(0xFFE53E3E),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: Color(0xFFE53E3E),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Version et informations
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  'Version 1.0.0 • © 2024 MADGI',
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}