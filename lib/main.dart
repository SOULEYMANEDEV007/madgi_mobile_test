import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/clique.dart';
import 'package:madgi_mobile/BlocAcceuil/validation.dart';
import 'package:screen_protector/screen_protector.dart';
import 'BlocAcceuil/acceuil.dart';
import 'BlocAcceuil/scane.dart';
import 'connexion.dart';
import 'inscription.dart';
import 'password.dart';
import 'splash_screen.dart';
import 'dart:io';

void main() {
  // ⚠️ DÉSACTIVER TEMPORAIREMENT LA VÉRIFICATION SSL POUR LE DÉVELOPPEMENT
  // ⚠️ À ENLEVER ABSOLUMENT AVANT LA PUBLICATION EN PRODUCTION
  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp());
  ScreenProtector.protectDataLeakageOn();
}

// Classe pour désactiver la vérification SSL (développement seulement)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // ⚠️ Accepter tous les certificats en développement
        // ⚠️ C'est une mesure temporaire pour le développement local
        print('⚠️ Accepting self-signed certificate for $host:$port');
        return true;
      };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madgi Mobile',
      theme: ThemeData(
        primaryColor: const Color(0xFF406ACC),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF406ACC),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAF7F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF406ACC),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF406ACC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      routes: {
        "/inscrire": (context) => const Inscription(),
        "/Qrscane": (context) => const Scane(),
        "/connecter": (context) => const Connexion(),
        "/passe": (context) => const Password(),
        "/clique": (context) => const Clique(),
        "/valider": (context) => const Validation(),
        "/home": (context) => const Accueil(),
      },
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}