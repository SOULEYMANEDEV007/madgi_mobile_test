// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:madgi_mobile/BlocAcceuil/clique.dart';
import 'package:madgi_mobile/BlocAcceuil/conger.dart';
import 'package:madgi_mobile/BlocAcceuil/contact_us.dart';
import 'package:madgi_mobile/BlocAcceuil/informations.dart';
import 'package:madgi_mobile/BlocAcceuil/menu.dart';
import 'package:madgi_mobile/BlocAcceuil/notification.dart';
import 'package:madgi_mobile/BlocAcceuil/profilscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'package:madgi_mobile/BlocAcceuil/actualites_completes.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  var userInfo;
  List infos = [];
  int quit = 0;
  Timer? _newsTimer;

  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00); // Orange principal
  static const Color secondaryColor = Color(0xFF009A44); // Vert ivoirien
  static const Color backgroundColor = Color(0xFFFFFFFF); // Blanc
  static const Color textColor = Color(0xFF2D3748); // Gris foncé pour texte
  static const Color lightGray = Color(0xFFF7FAFC); // Gris très clair
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color accentColor = Color(0xFF2B6CB0); // Bleu pour accents

  // Liste des images d'actualités depuis assets
  final List<Map<String, String>> actualites = [
    {
      'image': 'assets/activite1.jpg',
      'title': 'Le PASS',
      'subtitle': 'Formation des délégués de la MADGI au siège',
      'badge': 'Nouveau',
    },
    {
      'image': 'assets/activite4.jpg',
      'title': 'Assemblée Générale',
      'subtitle': 'La mutuelle fait son bilan annuel',
      'badge': 'Événement',
    },
    {
      'image': 'assets/activite6.jpg',
      'title': 'Campagne Spéciale',
      'subtitle': 'Découvrez nos dernières offres promotionnelles',
      'badge': 'Promo',
    },
  ];

  Future getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('userInfo');

      if (userInfoString == null) {
        print('❌ userInfo non trouvé dans SharedPreferences');
        return;
      }

      final userData = json.decode(userInfoString);
      setState(() {
        userInfo = userData['user'];
      });
      final token = userData['token'];
      final userId = userData['user']['id'];

      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

      var request =
          http.Request('GET', Uri.parse('${dotenv.get('API_URL')}/user-info'));
      request.body = json.encode({'user_id': userId});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      if (decode['success'] == true) {
        setState(() {
          userInfo = decode['data']['user'];
        });
        getInfo();
      } else {
        print('❌ Erreur API user-info: ${decode['message']}');
      }
    } catch (e) {
      print('❌ Erreur getUserInfo: $e');
    }
  }

  Future getInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('userInfo');

      if (userInfoString == null) {
        print('❌ userInfo non trouvé pour getInfo');
        return;
      }

      final userData = json.decode(userInfoString);
      final token = userData['token'];
      final userId = userData['user']['id'];

      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

      var request =
          http.Request('GET', Uri.parse('${dotenv.get('API_URL')}/infos'));
      request.body = json.encode({'user_id': userId});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      if (decode['success'] == true) {
        setState(() => infos = decode['data']);
      } else {
        print('❌ Erreur API infos: ${decode['message']}');
      }
    } catch (e) {
      print('❌ Erreur getInfo: $e');
    }
  }

  void close() async {
    setState(() => quit += 1);
    if (quit == 1) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Êtes-vous sûr de fermer l\'application ?',
            style: TextStyle(fontSize: 16),
          ),
          content: const Text('Appuyer encore pour quitter'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => quit = 0);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                exit(0);
              },
              child: const Text('Quitter'),
            ),
          ],
        ),
      );

      Timer(const Duration(seconds: 2), () {
        if (quit == 1) {
          setState(() => quit = 0);
        }
      });
    } else {
      exit(0);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    _startAutoScrollNews();
  }

  void _startAutoScrollNews() {
    _newsTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= actualites.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    double iconSize = 30,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(actualites.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? primaryColor : mediumGray,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatName() {
    if (userInfo == null) return 'Chargement...';
    String nom = userInfo['nom']?.toString() ?? '';
    String prenom = userInfo['prenom']?.toString() ?? '';
    List<String> prenoms = prenom.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    String premierPrenom = prenoms.isNotEmpty ? prenoms.first : '';
    return '$nom $premierPrenom'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        /*title: Text(
          'MADGI',
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),*/
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: primaryColor,
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (userInfo != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                  image: userInfo['photo'] != null
                      ? DecorationImage(
                          image: NetworkImage(
                              "${dotenv.get('IMAGE_URL')}/${userInfo['photo']}"),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: userInfo['photo'] == null
                    ? const Icon(
                        Icons.person,
                        color: primaryColor,
                        size: 20,
                      )
                    : null,
              ),
            ),
          const SizedBox(width: 4),
          Stack(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mediumGray,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: textColor,
                    size: 22,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Notifications(),
                    ),
                  );
                },
              ),
              if (userInfo != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE53E3E),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${infos.length - infos.where((element) => element['info']['userinfos']?['user_id'] == userInfo['id']).toList().length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: Drawer(
        child: Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              secondary: secondaryColor,
            ),
          ),
          child: Container(
            color: backgroundColor,
            child: const Menu(),
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (value) => close(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section de bienvenue
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour,',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _formatName(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 22,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bienvenue sur votre espace personnel',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Section actualités (carousel)
              const SizedBox(height: 12),
              // ... dans le build method, dans la section Actualités
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Actualités',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigation vers l'écran des actualités complètes
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ActualitesCompletesScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Voir tout',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),*/
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: actualites.length,
                  itemBuilder: (context, index) {
                    final actualite = actualites[index];
                    return _buildNewsSlide(
                      imageAsset: actualite['image']!,
                      title: actualite['title']!,
                      subtitle: actualite['subtitle']!,
                      badgeText: actualite['badge']!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildSlideIndicator(),

              // Section services - FIXE (non scrollable)
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Services rapides',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Section services FIXE (ne scroll plus)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Grille de services (2x2) restaurée
                        GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.25,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildServiceCard(
                              icon: Icons.message_outlined,
                              title: 'Informations',
                              color: secondaryColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Informations(),
                                  ),
                                );
                              },
                            ),
                            _buildServiceCard(
                              icon: Icons.beach_access,
                              title: 'Gestion des congés',
                              color: accentColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Conger(),
                                  ),
                                );
                              },
                            ),
                            _buildServiceCard(
                              icon: Icons.check_circle,
                              title: 'Pointage\nEmarger',
                              color: primaryColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Clique()),
                                );
                              },
                              iconSize: 28,
                            ),
                            _buildServiceCard(
                              icon: Icons.contact_emergency,
                              title: 'Contactez Nous',
                              color: const Color(0xFF805AD5),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ContactPage()),
                                );
                              },
                              iconSize: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).padding.bottom > 0 ? 85 : 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 10,
            top: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_filled,
                label: 'Accueil',
                isActive: true,
              ),
              _buildNavItem(
                icon: Icons.beach_access,
                label: 'Congés',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Conger(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.info_outline,
                label: 'Infos',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Informations(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsSlide({
    required String imageAsset,
    required String title,
    required String subtitle,
    String? badgeText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: primaryColor.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Image de fond depuis assets
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback si l'image n'existe pas dans assets
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.3),
                          secondaryColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.newspaper,
                            color: Colors.white.withOpacity(0.5),
                            size: 60,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Overlay avec contenu
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? primaryColor.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: isActive ? primaryColor : textColor.withOpacity(0.6),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryColor : textColor.withOpacity(0.6),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
