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

      var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/user-info'));
      request.body = json.encode({'user_id': userId});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      if (decode['success'] == true) {
        setState(() {
          userInfo = decode['data']['user'];
        });
        getInfo(); // Appeler getInfo APRÈS avoir récupéré userInfo
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

      var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/infos'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.amber,
        title: Center(
          child: Image.asset(
            'assets/images.jpg',
            height: 40,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Notifications(),
                ),
              );
            },
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: -10, end: -12),
              badgeContent: Text(
                userInfo != null
                    ? '${infos.length - infos.where((element) => element['info']['userinfos']?['user_id'] == userInfo['id']).toList().length}'
                    : '0',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              child: const Icon(
                  Icons.notifications,
                  size: 30,
                  color: Color.fromARGB(255, 174, 172, 172)
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: Theme(
          data: ThemeData.dark(),
          child: Container(
            child: const Menu(),
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (value) => close(),
        child: Container(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Bonjour, ',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      userInfo != null ? userInfo['nom'] ?? '' : 'Chargement...',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    Container(
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/activite1.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          const Positioned(
                            bottom: 10,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Le PASS",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  "Formation des délégués de la MADGI au siège",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/activite4.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          const Positioned(
                            bottom: 10,
                            left: 10,
                            child: Text(
                              'Assemblée Générale mixte: La mutelle fait son bilan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Image.asset(
                        'assets/activite6.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == i ? Colors.blue : Colors.grey,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Informations(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF406ACC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    width: double.infinity,
                                    height: (300 / 2) - 2.5,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.message_outlined,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Informations',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Conger(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA7BAE8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    width: double.infinity,
                                    height: (300 / 2) - 2.5,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.beach_access,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Congés',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: InkWell(
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
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCBA6C),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Emarger',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 25,
              offset: Offset(0, -3),
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 28, right: 28, top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, color: Color(0xFF406ACC)),
                    onPressed: () {
                      // Déjà sur la page d'accueil
                    },
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Accueil',
                    style: TextStyle(
                      color: Color(0xFF406ACC),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.beach_access, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Conger(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Congé',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.history, color: Color(0xFF0F0F0F)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Informations(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Informations',
                    style: TextStyle(
                      color: Color(0xFF0F0F0F),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: userInfo != null && userInfo['photo'] != null
                          ? NetworkImage('https://rh.madgi.ci/${userInfo['photo']}')
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                      child: userInfo == null || userInfo['photo'] == null
                          ? const Icon(Icons.person, size: 16, color: Colors.grey)
                          : null,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Profil',
                    style: TextStyle(
                      color: Color(0xFF0F0F0F),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}