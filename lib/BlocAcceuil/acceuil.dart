// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/clique.dart';
import 'package:madgi_mobile/BlocAcceuil/conger.dart';
import 'package:madgi_mobile/BlocAcceuil/informations.dart';
import 'package:madgi_mobile/BlocAcceuil/menu.dart';
import 'package:madgi_mobile/BlocAcceuil/notification.dart';
import 'package:madgi_mobile/BlocAcceuil/profilscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;

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

  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00); // Orange principal
  static const Color secondaryColor = Color(0xFF009A44); // Vert ivoirien
  static const Color backgroundColor = Color(0xFFFFFFFF); // Blanc
  static const Color textColor = Color(0xFF2D3748); // Gris foncé pour texte
  static const Color lightGray = Color(0xFFF7FAFC); // Gris très clair
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color accentColor = Color(0xFF2B6CB0); // Bleu pour accents

  Future getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('userInfo');

      if (userInfoString == null) {
        print('❌ userInfo non trouvé dans SharedPreferences');
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

      var request = http.Request('GET', Uri.parse('http://rh.madgi.ci/api/v1/user-info'));
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

      var request = http.Request('GET', Uri.parse('http://192.168.1.12:8000/api/v1/infos'));
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
              width: 56,
              height: 56,
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
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images.jpg',
          height: 40,
          fit: BoxFit.contain,
        ),
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
                    size: 24,
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
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${infos.length - infos.where((element) => element['info']['userinfos']?['user_id'] == userInfo['id']).toList().length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withOpacity(0.1),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: userInfo != null && userInfo['photo'] != null
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://rh.madgi.ci/${userInfo['photo']}'),
                          )
                              : Icon(
                            Icons.person,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                userInfo != null ? userInfo['nom'] ?? '' : 'Chargement...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 20,
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
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Actualités',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildNewsSlide(
                      image: 'assets/activite1.jpg',
                      title: 'Le PASS',
                      subtitle: 'Formation des délégués de la MADGI au siège',
                    ),
                    _buildNewsSlide(
                      image: 'assets/activite4.jpg',
                      title: 'Assemblée Générale',
                      subtitle: 'La mutuelle fait son bilan annuel',
                    ),
                    _buildNewsSlide(
                      image: 'assets/activite6.jpg',
                      title: 'Événements',
                      subtitle: 'Découvrez nos dernières activités',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSlideIndicator(),

              // Section services
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Services rapides',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
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
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Clique()),
                            );
                          } catch (e) {
                            print('❌ Erreur navigation vers Clique: $e');
                          }
                        },
                        iconSize: 32,
                      ),
                      _buildServiceCard(
                        icon: Icons.calendar_today,
                        title: 'Planning',
                        color: const Color(0xFF805AD5),
                        onTap: () {
                          // Ajouter la navigation vers Planning
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
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
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
    );
  }

  Widget _buildNewsSlide({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : textColor.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryColor : textColor.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}