import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {

  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);

  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Contactez-nous'),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: const TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(context),
            const SizedBox(height: 30),

            // Description
            _buildDescription(),
            const SizedBox(height: 40),

            // Contacts des développeurs
            _buildContactsSection(),
            const SizedBox(height: 40),

            // Email de support
            _buildSupportSection(),
            const SizedBox(height: 40),

            // Horaires de support
            _buildSupportHours(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: primaryColor,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support Technique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nous sommes là pour vous aider',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Besoin d\'aide ?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Contactez notre équipe de développement pour signaler un bug, '
              'suggérer une amélioration ou obtenir de l\'aide technique.',
          style: TextStyle(
            fontSize: 16,
            color: textColor.withOpacity(0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Développeurs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contactez directement nos développeurs',
          style: TextStyle(
            color: textColor.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),

        // Contact 1
        _buildContactCard(
          name: 'Goh_dev',
          role: 'Responsable des Devs de CI+ et dev backend',
          phone: '+225 07 57 72 76 88',
          email: 'contact@madgi.com',
          color: secondaryColor.withOpacity(0.15),
        ),
        const SizedBox(height: 16),

        // Contact 2
        _buildContactCard(
          name: 'Souley_dev',
          role: 'Stagiaire et dev full stack',
          phone: '+225 01 51 78 25 66',
          email: 'contact@madgi.com',
          color: primaryColor.withOpacity(0.15),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required String name,
    required String role,
    required String phone,
    required String email,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role,
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: mediumGray),
            const SizedBox(height: 12),

            // Téléphone
            _buildContactRow(
              icon: Icons.phone,
              text: phone,
              onTap: () => _launchPhoneCall(phone),
            ),
            const SizedBox(height: 12),

            // Email
            _buildContactRow(
              icon: Icons.email,
              text: email,
              onTap: () => _launchEmail(email),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: mediumGray),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Support par Email',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Pour les problèmes techniques urgents, écrivez-nous directement à :',
            style: TextStyle(
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchEmail('support@madgi.com'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'support@madgi.com',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Réponse sous 24h',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Merci de préciser dans votre email :\n• Votre nom/prénom\n• Votre numéro de téléphone\n• Une description détaillée du problème\n• Une capture d\'écran si possible',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horaires de support',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lundi - Vendredi : 9h - 18h\nSamedi : 10h - 14h',
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonctions pour lancer les actions
  Future<void> _launchPhoneCall(String phoneNumber) async {
    final url = 'tel:${phoneNumber.replaceAll(' ', '')}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir le téléphone';
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir l\'application email';
    }
  }
}