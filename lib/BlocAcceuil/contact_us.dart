import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactez-nous'),
        backgroundColor: Colors.blue, // Adaptez la couleur à votre thème
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: Colors.blue.shade700,
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
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nous sommes là pour vous aider',
                  style: TextStyle(
                    color: Colors.blue.shade600,
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
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Contactez notre équipe de développement pour signaler un bug, '
              'suggérer une amélioration ou obtenir de l\'aide technique.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
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
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contactez directement nos développeurs',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),

        // Contact 1
        _buildContactCard(
          name: 'Jean Dupont',
          role: 'Lead Développeur',
          phone: '+33 6 12 34 56 78',
          email: 'jean.dupont@madgi.com',
          color: Colors.blue.shade100,
        ),
        const SizedBox(height: 16),

        // Contact 2
        _buildContactCard(
          name: 'Marie Martin',
          role: 'Développeuse Mobile',
          phone: '+33 6 23 45 67 89',
          email: 'marie.martin@madgi.com',
          color: Colors.green.shade100,
        ),
        const SizedBox(height: 16),

        // Contact 3
        _buildContactCard(
          name: 'Paul Bernard',
          role: 'Support Technique',
          phone: '+33 6 34 56 78 90',
          email: 'paul.bernard@madgi.com',
          color: Colors.orange.shade100,
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
                    color: Colors.grey.shade700,
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
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
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
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue.shade700,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
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
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.purple.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Support par Email',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Pour les problèmes techniques urgents, écrivez-nous directement à :',
            style: TextStyle(
              color: Colors.grey.shade700,
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
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline,
                    color: Colors.purple.shade700,
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
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Réponse sous 24h',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: Colors.purple.shade400,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Merci de préciser dans votre email :\n• Votre nom/prénom\n• Votre numéro de téléphone\n• Une description détaillée du problème\n• Une capture d\'écran si possible',
            style: TextStyle(
              color: Colors.grey.shade600,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: Colors.orange.shade700,
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
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lundi - Vendredi : 9h - 18h\nSamedi : 10h - 14h',
                  style: TextStyle(
                    color: Colors.grey.shade600,
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