import 'package:flutter/material.dart';

class ActualitesCompletesScreen extends StatefulWidget {
  const ActualitesCompletesScreen({Key? key}) : super(key: key);

  @override
  State<ActualitesCompletesScreen> createState() => _ActualitesCompletesScreenState();
}

class _ActualitesCompletesScreenState extends State<ActualitesCompletesScreen> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);

  // Liste complète des actualités (vous pouvez étendre cette liste)
  final List<Map<String, dynamic>> toutesActualites = [
    {
      'id': 1,
      'image': 'assets/activite1.jpg',
      'title': 'Le PASS',
      'subtitle': 'Formation des délégués de la MADGI au siège',
      'badge': 'Nouveau',
      'date': '15 Nov 2024',
      'description': 'Formation intensive des délégués de la Mutuelle pour une meilleure gestion des dossiers des membres.',
      'categorie': 'Formation',
      'likes': 24,
      'commentaires': 8,
    },
    {
      'id': 2,
      'image': 'assets/activite4.jpg',
      'title': 'Assemblée Générale',
      'subtitle': 'La mutuelle fait son bilan annuel',
      'badge': 'Événement',
      'date': '10 Déc 2024',
      'description': 'L\'assemblée générale annuelle a permis de faire le bilan des activités et de présenter les perspectives pour l\'année à venir.',
      'categorie': 'Administratif',
      'likes': 45,
      'commentaires': 12,
    },
    {
      'id': 3,
      'image': 'assets/activite6.jpg',
      'title': 'Campagne Spéciale',
      'subtitle': 'Découvrez nos dernières offres promotionnelles',
      'badge': 'Promo',
      'date': '5 Jan 2025',
      'description': 'Nouvelle campagne de recrutement avec des avantages exclusifs pour les nouveaux adhérents.',
      'categorie': 'Promotion',
      'likes': 31,
      'commentaires': 15,
    },
    {
      'id': 4,
      'image': 'assets/activite2.jpg', // Remplacez par vos images
      'title': 'Journée Portes Ouvertes',
      'subtitle': 'Découverte des services de la MADGI',
      'badge': 'Événement',
      'date': '20 Fév 2025',
      'description': 'Venez découvrir nos services et rencontrer notre équipe lors de notre journée portes ouvertes.',
      'categorie': 'Événement',
      'likes': 18,
      'commentaires': 6,
    },
    {
      'id': 5,
      'image': 'assets/activite3.jpg', // Remplacez par vos images
      'title': 'Formation Digitalisation',
      'subtitle': 'Apprendre à utiliser notre application mobile',
      'badge': 'Formation',
      'date': '8 Mar 2025',
      'description': 'Session de formation pour aider nos membres à maîtriser l\'application MADGI Mobile.',
      'categorie': 'Technologie',
      'likes': 29,
      'commentaires': 11,
    },
    {
      'id': 6,
      'image': 'assets/activite7.jpg', // Remplacez par vos images
      'title': 'Nouveaux Services',
      'subtitle': 'Extension de notre couverture santé',
      'badge': 'Nouveau',
      'date': '15 Mar 2025',
      'description': 'La MADGI étend sa couverture santé avec de nouveaux partenariats hospitaliers.',
      'categorie': 'Services',
      'likes': 52,
      'commentaires': 23,
    },
    {
      'id': 7,
      'image': 'assets/activite8.jpg', // Remplacez par vos images
      'title': 'Retraite Solidaire',
      'subtitle': 'Programme d\'accompagnement des retraités',
      'badge': 'Social',
      'date': '1 Avr 2025',
      'description': 'Nouveau programme d\'accompagnement et de soutien pour nos membres retraités.',
      'categorie': 'Social',
      'likes': 37,
      'commentaires': 17,
    },
    /*{
      'id': 8,
      'image': 'assets/activite4.jpg', // Remplacez par vos images
      'title': 'Concours Internes',
      'subtitle': 'Promotion interne des agents',
      'badge': 'Carrière',
      'date': '10 Avr 2025',
      'description': 'Organisation des concours internes pour la promotion des agents de la mutuelle.',
      'categorie': 'Ressources Humaines',
      'likes': 22,
      'commentaires': 9,
    },*/
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Toutes les actualités',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: primaryColor),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header avec stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.newspaper,
                  value: '${toutesActualites.length}',
                  label: 'Actualités',
                ),
                Container(height: 30, width: 1, color: mediumGray),
                _buildStatItem(
                  icon: Icons.event,
                  value: '5',
                  label: 'Événements',
                ),
                Container(height: 30, width: 1, color: mediumGray),
                _buildStatItem(
                  icon: Icons.celebration,
                  value: '3',
                  label: 'Nouveautés',
                ),
              ],
            ),
          ),

          // Liste des actualités
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: toutesActualites.length,
              itemBuilder: (context, index) {
                final actualite = toutesActualites[index];
                return _buildActualiteCard(actualite);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryColor, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActualiteCard(Map<String, dynamic> actualite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image avec badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  actualite['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: primaryColor.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.newspaper,
                          color: primaryColor.withOpacity(0.3),
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(actualite['badge']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    actualite['badge'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Catégorie et date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        actualite['categorie'],
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      actualite['date'],
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Titre
                Text(
                  actualite['title'],
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Sous-titre
                Text(
                  actualite['subtitle'],
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  actualite['description'],
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Footer avec interactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Likes et commentaires
                    Row(
                      children: [
                        _buildInteractionButton(
                          icon: Icons.thumb_up_outlined,
                          count: actualite['likes'],
                          onPressed: () {
                            // Action like
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildInteractionButton(
                          icon: Icons.comment_outlined,
                          count: actualite['commentaires'],
                          onPressed: () {
                            _showCommentsDialog(actualite);
                          },
                        ),
                      ],
                    ),

                    // Bouton Lire plus
                    ElevatedButton(
                      onPressed: () {
                        _showActualiteDetail(actualite);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Lire plus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: mediumGray, size: 18),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: mediumGray,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(String badge) {
    switch (badge) {
      case 'Nouveau':
        return secondaryColor;
      case 'Événement':
        return const Color(0xFF805AD5);
      case 'Promo':
        return const Color(0xFFDD6B20);
      case 'Social':
        return const Color(0xFF3182CE);
      case 'Carrière':
        return const Color(0xFF38A169);
      default:
        return primaryColor;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mediumGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filtrer les actualités',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterChip('Toutes les catégories', true),
              _buildFilterChip('Événements', false),
              _buildFilterChip('Nouveautés', false),
              _buildFilterChip('Formations', false),
              _buildFilterChip('Promotions', false),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Appliquer les filtres',
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
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (bool value) {
          // Gérer la sélection
        },
        selectedColor: primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : textColor,
        ),
      ),
    );
  }

  void _showCommentsDialog(Map<String, dynamic> actualite) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Commentaires',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  actualite['title'],
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                // Liste des commentaires (simulée)
                _buildCommentItem('Marie K.', 'Très intéressant, merci pour l\'information !', '2h'),
                _buildCommentItem('Jean D.', 'J\'aimerais en savoir plus sur cette formation.', '4h'),
                _buildCommentItem('Paul M.', 'Excellente initiative de la part de la MADGI.', '1j'),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: primaryColor),
                      onPressed: () {},
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(String name, String comment, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showActualiteDetail(Map<String, dynamic> actualite) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: mediumGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            actualite['image'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Titre et badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(actualite['badge']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                actualite['badge'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              actualite['date'],
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Titre
                        Text(
                          actualite['title'],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Sous-titre
                        Text(
                          actualite['subtitle'],
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Description complète
                        Text(
                          '${actualite['description']} Ceci est une description plus détaillée de l\'actualité. Vous pouvez ajouter autant de contenu que nécessaire ici. La MADGI continue d\'innover pour offrir les meilleurs services à ses membres.',
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDetailAction(
                              icon: Icons.share_outlined,
                              label: 'Partager',
                              onTap: () {
                                // Action partage
                              },
                            ),
                            _buildDetailAction(
                              icon: Icons.bookmark_border,
                              label: 'Sauvegarder',
                              onTap: () {
                                // Action sauvegarde
                              },
                            ),
                            _buildDetailAction(
                              icon: Icons.print_outlined,
                              label: 'Imprimer',
                              onTap: () {
                                // Action impression
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.1),
          ),
          child: IconButton(
            icon: Icon(icon, color: primaryColor),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}