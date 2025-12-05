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
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00); // Orange principal
  static const Color secondaryColor = Color(0xFF009A44); // Vert ivoirien
  static const Color backgroundColor = Color(0xFFFFFFFF); // Blanc
  static const Color textColor = Color(0xFF2D3748); // Gris foncé pour texte
  static const Color lightGray = Color(0xFFF7FAFC); // Gris très clair
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF38A169); // Vert succès
  static const Color warningColor = Color(0xFFDD6B20); // Orange avertissement
  static const Color errorColor = Color(0xFFE53E3E); // Rouge erreur

  List items = [];
  bool isLoading = true;
  String? userMatricule;
  String? userToken;
  String? userName;

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
        userName = userInfo['user']['nom'] ?? 'Utilisateur';
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
        Uri.parse('http://192.168.1.12:8000/api/v1/registers'),
        headers: headers,
      );

      print('📤 Requête envoyée à: http://192.168.1.12:8000/api/v1/registers');
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
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Afficher un snackbar de succès
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Gérer le retour du scan QR code
  void _handleScanResult(String? scanResult) async {
    if (scanResult == null || scanResult.isEmpty) {
      print('❌ Scan annulé ou vide');
      return;
    }

    print('🔍 QR Code scanné (tronqué): ${scanResult.length > 200 ? scanResult.substring(0, 200) + '...' : scanResult}');

    try {
      // Essayer de parser le QR code comme JSON
      final qrData = json.decode(scanResult);
      final sessionId = qrData['session_id']?.toString();

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

      // Gestion sécurisée de l'expiration
      DateTime expiresAt;
      try {
        final expiresAtStr = qrData['expires_at']?.toString();
        if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
          expiresAt = DateTime.parse(expiresAtStr);
        } else {
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

      // Si le QR code n'est pas un JSON valide
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

      final Map<String, dynamic> requestBody = {
        'matricule': matricule,
        'scan_time': DateTime.now().toIso8601String(),
      };

      if (sessionId != null && sessionId.isNotEmpty) {
        requestBody['session_id'] = sessionId;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.12:8000/api/v1/scan-emargement'),
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
        _showSuccessSnackbar(result['message'] ?? 'Pointage enregistré avec succès');
        await getRegister();
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
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: successColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pointage validé',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (pointageData != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: primaryColor, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${pointageData['nom'] ?? ''} ${pointageData['prenom'] ?? ''}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: primaryColor, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Date: ${pointageData['date'] ?? ''}',
                                style: TextStyle(color: textColor.withOpacity(0.7)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.login, color: primaryColor, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Arrivée: ${pointageData['heure_arrive'] ?? ''}',
                                style: TextStyle(color: textColor.withOpacity(0.7)),
                              ),
                            ],
                          ),
                          if (pointageData['heure_depart'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.logout, color: primaryColor, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Départ: ${pointageData['heure_depart']}',
                                  style: TextStyle(color: textColor.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ],
                          if (pointageData['est_en_retard'] == true) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: warningColor, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Retard signalé',
                                    style: TextStyle(
                                      color: warningColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() => isLoading = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
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
        ),
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
                      builder: (context) => const Accueil(),
                    ),
                  );
                },
              ),
              Expanded(
                child: Text(
                  'Pointage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: lightGray,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.refresh, color: primaryColor, size: 20),
                ),
                onPressed: isLoading ? null : getRegister,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Scannez le QR code pour pointer',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: InkWell(
          onTap: () async {
            if (userMatricule == null) {
              _showErrorSnackbar('Informations utilisateur non chargées');
              return;
            }

            final scanResult = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => const Scane(back: true),
              ),
            );

            _handleScanResult(scanResult);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: mediumGray, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Cadre de scan inspiré de WhatsApp
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Cadre avec coins arrondis
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _WhatsAppScannerPainter(),
                        ),
                      ),

                      // Centre du scanner
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: primaryColor.withOpacity(0.5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      // Animation de scan
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0),
                                primaryColor,
                                primaryColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Icon(
                  Icons.qr_code_scanner,
                  color: primaryColor,
                  size: 40,
                ),

                const SizedBox(height: 16),

                Text(
                  'SCANNER POUR POINTER',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Cliquez puis scannez le QR code de pointage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Valable 5 secondes seulement',
                    style: TextStyle(
                      color: warningColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mediumGray),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? 'Chargement...',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userMatricule != null
                      ? 'Matricule: $userMatricule'
                      : 'Chargement du matricule...',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointageCard(Map<String, dynamic> item) {
    final isLate = item['est_en_retard'] == true;
    final isEarlyDeparture = item['est_depart_anticipe'] == true;
    final hasDeparture = item['heure_depart'] != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: mediumGray, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date(item['date']),
                      style: TextStyle(
                        color: textColor,
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
                              color: warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Retard',
                              style: TextStyle(
                                color: warningColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (isEarlyDeparture)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Départ anticipé',
                              style: TextStyle(
                                color: errorColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimeItem(
                      Icons.login,
                      'Arrivée',
                      item['heure_arrive'] ?? '--:--',
                      successColor,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: mediumGray,
                    ),
                    _buildTimeItem(
                      Icons.logout,
                      'Départ',
                      item['heure_depart'] ?? '--:--',
                      hasDeparture ? primaryColor : mediumGray,
                    ),
                  ],
                ),
                if (hasDeparture) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: secondaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Journée complète',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeItem(IconData icon, String label, String time, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun pointage',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Scannez le QR code pour enregistrer votre premier pointage',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: backgroundColor,
                onRefresh: () async {
                  await getRegister();
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildUserInfoCard(),
                      _buildScanCard(),

                      // Section historique
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Historique des pointages',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      isLoading
                          ? Container(
                        padding: const EdgeInsets.only(top: 40, bottom: 80),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: primaryColor),
                            const SizedBox(height: 16),
                            Text(
                              'Chargement des pointages...',
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                          : (items.isEmpty)
                          ? _buildEmptyState()
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildPointageCard(items[index]);
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe pour dessiner le cadre de scan style WhatsApp
class _WhatsAppScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF77F00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dessiner le cadre extérieur
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);

    // Dessiner les coins (style WhatsApp)
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = const Color(0xFFF77F00)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Coin supérieur gauche
    canvas.drawLine(Offset(0, cornerLength), Offset(0, 0), cornerPaint);
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), cornerPaint);

    // Coin supérieur droit
    canvas.drawLine(Offset(size.width - cornerLength, 0), Offset(size.width, 0), cornerPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), cornerPaint);

    // Coin inférieur gauche
    canvas.drawLine(Offset(0, size.height - cornerLength), Offset(0, size.height), cornerPaint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), cornerPaint);

    // Coin inférieur droit
    canvas.drawLine(Offset(size.width - cornerLength, size.height), Offset(size.width, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height - cornerLength), Offset(size.width, size.height), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}