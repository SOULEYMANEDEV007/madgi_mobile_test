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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changer la couleur de fond en blanc
      body: SizedBox(
        
        child: Column(
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer horizontalement
            crossAxisAlignment: CrossAxisAlignment.center, // Centrer verticalement
            children: [
              Image.asset(
                "assets/images.jpg",
                height: 90,
                width: 80,
              ),
              const SizedBox(width: 10), // Ajout d'un espace entre l'image et le texte
              const Text(
                "MADGI",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.home_outlined,
                        color: Colors.black, 
                      ),
                      title: const Text(
                        'Accueil',
                        style: TextStyle(
                          color: Colors.black, // Couleur du texte en noir
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Accueil(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.black, // Couleur des icônes en noir
                      ),
                      title: const Text(
                        'Emargement',
                        style: TextStyle(
                          color: Colors.black, 
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => Scane(back: true),
                            builder: (context) => Acceuil(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.event_note,
                        color: Colors.black, 
                      ),
                      title: const Text(
                        'Congés & Absences',
                        style: TextStyle(
                          color: Colors.black, // Couleur du texte en noir
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Conger(back: true),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      color: Colors.blue, // Couleur du trait en bleu
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 1.9),
                    ListTile(
                      leading: const Icon(
                        Icons.person_outline,
                        color: Colors.black, // Couleur des icônes en noir
                      ),
                      title: const Text(
                        'Profil',
                        style: TextStyle(
                          color: Colors.black, // Couleur du texte en noir
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(back: true),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.power_settings_new,
                        color: Colors.black, 
                      ),
                      title: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: Colors.black, 
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text(
                                    'Voulez-vous vous déconnecter?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                const Divider(
                                  color: Colors.blue,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/home');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Non',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        var headers = {
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json',
                                          'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
                                        };
                                        var request = http.Request('POST', Uri.parse('https://rh.madgi.ci/api/v1/logout'));
                                        request.headers.addAll(headers);
                                        http.StreamedResponse response = await request.send();
                                        final data = await response.stream.bytesToString();
                                        final decode = json.decode(data);
                                        if (decode['code'] == 200) {
                                          final prefs = await SharedPreferences.getInstance();
                                          prefs.clear();
                                          Navigator.pushNamed(context, '/connecter');
                                        }
                                        else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.black,
                                              content: Text(
                                                'Une erreur est survenue',
                                              )
                                            )
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Oui',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      },
                    ),
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
