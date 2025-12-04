import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:madgi_mobile/BlocAcceuil/scane.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Clique extends StatefulWidget {
  final bool back;
  const Clique({super.key, this.back = false});

  @override
  State<Clique> createState() => _CliqueState();
}

class _CliqueState extends State<Clique> {
  List items = [];
  bool isLoading = true;
  String? userMatricule;
  String? userToken;

  // Initialisation - Récupérer les infos utilisateur
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('userInfo');

      if (userInfoString == null) {
        print('❌ Erreur: userInfo non trouvé dans SharedPreferences');
        return;
      }

      final userInfo = json.decode(userInfoString);
      setState(() {
        userToken = userInfo['token'];
        userMatricule = userInfo['user']['matricule']?.toString();
      });

      print('✅ Utilisateur chargé - Matricule: $userMatricule');
      print('✅ Token: ${userToken?.substring(0, 20)}...');
    } catch (e) {
      print('❌ Erreur chargement infos utilisateur: $e');
    }
  }

  // Récupérer l'historique des pointages
  Future<void> getRegister() async {
    if (userToken == null) {
      print('❌ Token non disponible');
      return;
    }

    try {
      setState(() => isLoading = true);

      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken'
      };

      final response = await http.get(
        Uri.parse('http://192.168.1.9:8000/api/v1/registers'),
        headers: headers,
      );

      print('📤 Requête envoyée à: http://192.168.1.9:8000/api/v1/registers');
      print('📥 Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decode = json.decode(response.body);

        if (decode['success'] == true) {
          setState(() {
            items = decode['data'] ?? [];
            isLoading = false;
          });
          print('✅ ${items.length} pointages chargés');
        } else {
          print('❌ Erreur API: ${decode['message']}');
          _showErrorSnackbar(decode['message'] ?? 'Erreur lors du chargement');
          setState(() => isLoading = false);
        }
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        _showErrorSnackbar('Erreur serveur (${response.statusCode})');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Erreur réseau: $e');
      _showErrorSnackbar('Erreur de connexion: $e');
      setState(() => isLoading = false);
    }
  }

  // Afficher un snackbar d'erreur
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Afficher un snackbar de succès
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Gérer le retour du scan QR code - CORRIGÉ
  void _handleScanResult(String? scanResult) async {
    if (scanResult == null || scanResult.isEmpty) {
      print('❌ Scan annulé ou vide');
      return;
    }

    print('🔍 QR Code scanné (tronqué): ${scanResult.length > 200 ? scanResult.substring(0, 200) + '...' : scanResult}');

    try {
      // Essayer de parser le QR code comme JSON
      final qrData = json.decode(scanResult);

      // CORRECTION : Extraire session_id avec sécurité
      final sessionId = qrData['session_id']?.toString();

      // CORRECTION : Gérer les matricules avec des null
      final rawMatricules = qrData['matricules'];
      final List<String> matricules = [];

      if (rawMatricules is List) {
        for (var item in rawMatricules) {
          if (item != null && item.toString().trim().isNotEmpty) {
            matricules.add(item.toString().trim());
          }
        }
      }

      print('📋 Nombre de matricules valides: ${matricules.length}');
      print('📋 Session ID: $sessionId');

      // CORRECTION : Gestion sécurisée de l'expiration
      DateTime expiresAt;
      try {
        final expiresAtStr = qrData['expires_at']?.toString();
        if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
          expiresAt = DateTime.parse(expiresAtStr);
        } else {
          // Fallback : timestamp + 10 secondes
          final timestamp = DateTime.parse(qrData['timestamp']?.toString() ?? DateTime.now().toIso8601String());
          expiresAt = timestamp.add(const Duration(seconds: 10));
        }
      } catch (e) {
        print('⚠️ Erreur parsing date, utilisation par défaut: $e');
        expiresAt = DateTime.now().add(const Duration(seconds: 10));
      }

      // Vérifier l'expiration
      if (DateTime.now().isAfter(expiresAt)) {
        _showErrorSnackbar('QR code expiré! Veuillez scanner un nouveau code.');
        return;
      }

      // Vérifier si l'utilisateur est autorisé
      if (userMatricule == null) {
        _showErrorSnackbar('Matricule utilisateur non disponible');
        return;
      }

      final userMatriculeClean = userMatricule!.trim();
      final isAuthorized = matricules.any((mat) => mat.trim() == userMatriculeClean);

      if (!isAuthorized) {
        print('❌ Matricule "$userMatriculeClean" non trouvé dans la liste');
        _showErrorSnackbar('Vous n\'êtes pas autorisé à pointer avec ce QR code');
        return;
      }

      // Envoyer le pointage à l'API
      await _sendPointageToAPI(sessionId);

    } catch (e, stackTrace) {
      print('❌ Erreur traitement QR: $e');
      print('📋 Stack trace: $stackTrace');

      // Si le QR code n'est pas un JSON valide, on traite comme un matricule direct
      print('⚠️ QR code non-JSON, traitement comme matricule direct');
      await _sendPointageToAPI(null, matriculeDirect: scanResult);
    }
  }

  // Envoyer le pointage à l'API
  Future<void> _sendPointageToAPI(String? sessionId, {String? matriculeDirect}) async {
    try {
      setState(() => isLoading = true);

      final matricule = matriculeDirect ?? userMatricule;

      if (matricule == null) {
        _showErrorSnackbar('Matricule non disponible');
        return;
      }

      print('📤 Envoi pointage pour matricule: $matricule');
      if (sessionId != null) print('🔑 Session ID: $sessionId');

      // CORRECTION : Construction sécurisée du body
      final Map<String, dynamic> requestBody = {
        'matricule': matricule,
        'scan_time': DateTime.now().toIso8601String(),
      };

      // Ajouter session_id seulement si non null
      if (sessionId != null && sessionId.isNotEmpty) {
        requestBody['session_id'] = sessionId;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.9:8000/api/v1/scan-emargement'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📥 Réponse API: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      final result = json.decode(response.body);

      if (result['code'] == 200) {
        _showSuccessSnackbar(result['message'] ?? 'Pointage enregistré');
        // Rafraîchir la liste des pointages
        await getRegister();

        // Afficher le détail du pointage
        _showPointageDetail(result['data']);
      } else {
        _showErrorSnackbar(result['message'] ?? 'Erreur lors du pointage');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Erreur envoi pointage: $e');
      _showErrorSnackbar('Erreur réseau: $e');
      setState(() => isLoading = false);
    }
  }

  // Afficher le détail du pointage
  void _showPointageDetail(dynamic pointageData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Pointage enregistré'),
          ],
        ),
        content: pointageData != null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 ${pointageData['nom'] ?? ''} ${pointageData['prenom'] ?? ''}'),
            const SizedBox(height: 10),
            Text('📅 Date: ${pointageData['date'] ?? ''}'),
            const SizedBox(height: 8),
            Text('🕗 Arrivée: ${pointageData['heure_arrive'] ?? ''}'),
            if (pointageData['heure_depart'] != null)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text('🕔 Départ: ${pointageData['heure_depart']}'),
                ],
              ),
            if (pointageData['est_en_retard'] == true)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text('⚠️ Retard', style: TextStyle(color: Colors.orange)),
                ],
              ),
            if (pointageData['est_depart_anticipe'] == true)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text('⚠️ Départ anticipé', style: TextStyle(color: Colors.orange)),
                ],
              ),
          ],
        )
            : const Text('Pointage effectué avec succès'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => isLoading = false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo().then((_) => getRegister());
  }

  String date(String date) {
    try {
      final convert = DateTime.parse(date);
      return formatDate(convert, [dd, '/', mm, '/', yyyy]);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Accueil(),
              ),
            );
          },
        ),
        title: const Text('Pointage'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : getRegister,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec informations
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF406ACC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userMatricule != null
                      ? 'Matricule: $userMatricule'
                      : 'Chargement...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scannez le QR code affiché sur la tablette de pointage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Bouton pour lancer le scan QR code
                    InkWell(
                      onTap: () async {
                        if (userMatricule == null) {
                          _showErrorSnackbar('Informations utilisateur non chargées');
                          return;
                        }

                        print('🎯 Lancement du scan QR code');

                        final scanResult = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Scane(back: true),
                          ),
                        );

                        _handleScanResult(scanResult);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF406ACC), Color(0xFF5A82E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 60,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'SCANNER POUR POINTER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cliquez ici puis scannez le QR code',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Valable 5 secondes seulement',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Titre de l'historique
                    const Row(
                      children: [
                        Icon(Icons.history, color: Color(0xFF406ACC), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Historique des pointages',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Indicateur de chargement ou liste des pointages
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 40, bottom: 40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF406ACC)),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chargement des pointages...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else if (items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun pointage enregistré',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Utilisez le bouton ci-dessus pour scanner\nle QR code et enregistrer votre premier pointage',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      RefreshIndicator(
                        onRefresh: getRegister,
                        color: const Color(0xFF406ACC),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, i) => Column(
                            children: [
                              if (i > 0) const SizedBox(height: 12),
                              _buildDemandCard(
                                context,
                                date: date(items[i]['date']),
                                arrivalTime: items[i]['heure_arrive'] ?? '--:--',
                                departureTime: items[i]['heure_depart'] ?? '--:--',
                                isLate: items[i]['est_en_retard'] == true,
                                isEarlyDeparture: items[i]['est_depart_anticipe'] == true,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandCard(
      BuildContext context, {
        required String date,
        required String arrivalTime,
        required String departureTime,
        bool isLate = false,
        bool isEarlyDeparture = false,
      }) {
    final hasDeparture = departureTime != '--:--';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isLate ? Colors.orange.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec date et statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF0F0F0F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  if (isLate)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, size: 12, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Retard',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isEarlyDeparture)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_off, size: 12, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Départ anticipé',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 16),

          // Heures d'arrivée et départ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeColumn(
                'Heure d\'arrivée',
                arrivalTime,
                arrivalTime != '--:--' ? Colors.green : Colors.grey,
                Icons.login,
              ),

              Container(
                width: 1,
                height: 50,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              _buildTimeColumn(
                'Heure de départ',
                departureTime,
                hasDeparture ? Colors.red : Colors.grey,
                Icons.logout,
              ),
            ],
          ),

          // Statut complet de la journée
          if (hasDeparture) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Journée complétée',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, String time, Color color, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
    );
  }
}