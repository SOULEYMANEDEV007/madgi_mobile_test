import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/conger.dart';

class Detail extends StatefulWidget {
  final data;
  const Detail({super.key, required this.data});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFDD6B20);
  static const Color errorColor = Color(0xFFE53E3E);

  Widget _buildStatusBadge(String status) {
    String label;
    Color badgeColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'ACCEPTÉ':
        label = 'Accepté';
        badgeColor = successColor;
        textColor = Colors.white;
        break;
      case 'ERROR':
      case 'REFUSÉ':
        label = 'Refusé';
        badgeColor = errorColor;
        textColor = Colors.white;
        break;
      default:
        label = 'En attente';
        badgeColor = warningColor;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Conger(),
                    ),
                  );
                },
              ),
              Expanded(
                child: Text(
                  'Détails de la demande',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.data['type'] ?? 'Type de congé',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: mediumGray, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Non spécifié',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isImportant ? textColor : textColor.withOpacity(0.9),
                fontSize: 14,
                fontWeight: isImportant ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: mediumGray,
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildFileAttachment() {
    if (widget.data['medias'] == null || widget.data['medias'].isEmpty) {
      return const SizedBox();
    }

    final firstMedia = widget.data['medias'].first;
    final imageUrl = "https://rh.madgi.ci/${firstMedia['src']}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document joint',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: mediumGray, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showImageViewer(
                      context,
                      Image.network(imageUrl).image,
                      backgroundColor: Colors.black.withOpacity(0.9),
                      onViewerDismissed: () {},
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: mediumGray, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              color: primaryColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: lightGray,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: mediumGray,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image non disponible',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    showImageViewer(
                      context,
                      Image.network(imageUrl).image,
                      backgroundColor: Colors.black.withOpacity(0.9),
                      onViewerDismissed: () {},
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: primaryColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in,
                        color: primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Agrandir l\'image',
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
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Non spécifié';

    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        return date;
      }

      // Si c'est un format ISO
      if (date.contains('-')) {
        final dateTime = DateTime.tryParse(date);
        if (dateTime != null) {
          return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
        }
      }

      return date;
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final congeData = widget.data['conge'];

    return Scaffold(
      backgroundColor: lightGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Informations personnelles
                    _buildInfoCard(
                      'Informations personnelles',
                      [
                        _buildInfoRow(
                          'Nom & prénom',
                          congeData['fullname'] ?? '',
                          isImportant: true,
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Matricule',
                          congeData['matricule'] ?? '',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Département',
                          widget.data['departement'] ?? '',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Service',
                          widget.data['service'] ?? '',
                        ),
                      ],
                    ),

                    // Personne à contacter
                    _buildInfoCard(
                      'Personne à contacter',
                      [
                        _buildInfoRow(
                          'Nom & prénom',
                          congeData['call_user_name'] ?? '',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Téléphone',
                          congeData['call_phone'] ?? '',
                        ),
                      ],
                    ),

                    // Détails de la demande
                    _buildInfoCard(
                      'Détails de la demande',
                      [
                        _buildInfoRow(
                          'Date de début',
                          _formatDate(congeData['start_date']),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Date de fin',
                          _formatDate(congeData['end_date']),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Lieu de jouissance',
                          congeData['place_enjoyment'] ?? '',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Intérimaire',
                          congeData['interim'] ?? '',
                        ),
                        _buildDivider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Statut de la demande',
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _buildStatusBadge(congeData['status'] ?? ''),
                          ],
                        ),
                      ],
                    ),

                    // Document joint
                    _buildFileAttachment(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}