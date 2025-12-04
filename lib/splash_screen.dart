// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BlocAcceuil/acceuil.dart';
import 'connexion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('userInfo')) {
      return Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Accueil(),
          ),
        );
    }
    else {
      return Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Connexion(),
          ),
        );
    }
  }
  
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images.jpg',
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              "la MADGI en un clic",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      nextScreen: const Connexion(),
      splashTransition: SplashTransition.fadeTransition,
      duration: 3000, // Durée du splash screen en millisecondes (ici, 3 secondes)
    );
  }
}