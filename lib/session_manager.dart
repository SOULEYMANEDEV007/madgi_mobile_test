import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clé globale pour naviguer de n'importe où
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class SessionManager extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionManager({
    Key? key,
    required this.child,
    // La durée standard pour les applications d'entreprise (15 minutes)
    this.timeoutDuration = const Duration(minutes: 15),
  }) : super(key: key);

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  void _resetTimer() {
    // Relance le compteur à chaque interaction
    _startTimer();
  }

  Future<void> _handleTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('userInfo');

    // On vérifie si l'utilisateur est effectivement connecté
    if (userInfoString != null) {
      // 1. Vider les données de session locales
      await prefs.remove('userInfo');
      await prefs.remove('token');
      
      // 2. Rediriger vers l'accueil (connexion) de façon sécurisée
      final navigator = globalNavigatorKey.currentState;
      if (navigator != null) {
        // Redirige vers /connecter et supprime tout l'historique de navigation
        navigator.pushNamedAndRemoveUntil('/connecter', (route) => false);
        
        // 3. Afficher un message explicatif
        final context = navigator.context;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.lock_clock, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Session expirée suite à une inactivité. Veuillez vous reconnecter.'),
                  ),
                ],
              ),
              backgroundColor: Color(0xFFDD6B20), // Orange (warning)
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le Listener enveloppe toute l'application et détecte toutes les interactions
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      // Capture aussi le scroll
      onPointerSignal: (_) => _resetTimer(), 
      child: widget.child,
    );
  }
}
