// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Scane extends StatefulWidget {
  final bool back;
  const Scane({super.key, this.back = false});

  @override
  State<Scane> createState() => _ScaneState();
}

class _ScaneState extends State<Scane> with SingleTickerProviderStateMixin {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00); // Orange principal
  static const Color secondaryColor = Color(0xFF009A44); // Vert ivoirien
  static const Color backgroundColor = Color(0xFFFFFFFF); // Blanc
  static const Color textColor = Color(0xFF2D3748); // Gris foncé pour texte
  static const Color lightGray = Color(0xFFF7FAFC); // Gris très clair
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF38A169); // Vert succès
  static const Color errorColor = Color(0xFFE53E3E); // Rouge erreur
  static const Color warningColor = Color(0xFFDD6B20); // Orange avertissement
  static const Color infoColor = Color(0xFF3182CE); // Bleu info
  static const Color successGradientStart = Color(0xFF00B09B);
  static const Color successGradientEnd = Color(0xFF96C93D);
  static const Color errorGradientStart = Color(0xFFFF416C);
  static const Color errorGradientEnd = Color(0xFFFF4B2B);

  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;
  bool _isLoading = false;
  bool _flashOn = false;
  String? _userMatricule;
  String? _userId;
  String? _userPrenom;
  String? _userNom;
  String? _userToken;
  TextEditingController _justificatifController = TextEditingController();

  // Animation controller pour les pop-ups
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  // Méthode pour générer des logs colorés avec timestamp
  void _log(String message, {String level = 'INFO'}) {
    final timestamp = DateTime.now().toIso8601String();
    final ansiReset = '\x1B[0m';
    String ansiColor;
    String emoji;

    switch (level) {
      case 'ERROR':
        ansiColor = '\x1B[31m'; // Rouge
        emoji = '❌';
        break;
      case 'WARNING':
        ansiColor = '\x1B[33m'; // Jaune
        emoji = '⚠️';
        break;
      case 'SUCCESS':
        ansiColor = '\x1B[32m'; // Vert
        emoji = '✅';
        break;
      case 'INFO':
        ansiColor = '\x1B[34m'; // Bleu
        emoji = 'ℹ️';
        break;
      case 'DEBUG':
        ansiColor = '\x1B[35m'; // Magenta
        emoji = '🐛';
        break;
      case 'SCAN':
        ansiColor = '\x1B[36m'; // Cyan
        emoji = '📱';
        break;
      default:
        ansiColor = '\x1B[37m'; // Blanc
        emoji = '📝';
    }

    print('$ansiColor[$timestamp] $emoji [$level] $message$ansiReset');
  }

  @override
  void initState() {
    super.initState();
    _log('Initialisation de l\'écran de scan', level: 'INFO');

    // Initialiser les animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadUserInfo();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _log('Contrôleur caméra initialisé', level: 'INFO');
  }

  Future<void> _loadUserInfo() async {
    _log('Chargement des informations utilisateur...', level: 'INFO');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('userInfo');

      if (userInfoString == null) {
        _log('Aucune information utilisateur trouvée', level: 'WARNING');
        return;
      }

      final userInfo = json.decode(userInfoString);
      setState(() {
        _userMatricule = userInfo['user']['matricule']?.toString();
        _userId = userInfo['user']['id']?.toString();
        _userPrenom = userInfo['user']['prenom']?.toString();
        _userNom = userInfo['user']['nom']?.toString();
        _userToken = userInfo['token']?.toString();
      });
      _log('Matricule utilisateur chargé: $_userMatricule', level: 'SUCCESS');
      _log('ID utilisateur chargé: $_userId', level: 'SUCCESS');
      _log('Prénom utilisateur chargé: $_userPrenom', level: 'SUCCESS');
    } catch (e) {
      _log('Erreur chargement infos utilisateur: $e', level: 'ERROR');
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () {
                  _log('Retour à l\'écran précédent', level: 'INFO');
                  Navigator.of(context).pop();
                },
              ),
              Expanded(
                child: Text(
                  'Scanner QR Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _flashOn ? Icons.flash_on : Icons.flash_off,
                  color: primaryColor,
                ),
                onPressed: () {
                  _log('Toggle flash: ${!_flashOn}', level: 'INFO');
                  setState(() => _flashOn = !_flashOn);
                  cameraController.toggleTorch();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_userMatricule != null)
            Text(
              'Matricule: $_userMatricule',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Expanded(
      child: Stack(
        children: [
          // Vue caméra
          MobileScanner(
            controller: cameraController,
            onDetect: _handleQRCodeDetect,
          ),

          // Overlay avec cadre de scan
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
              child: CustomPaint(
                painter: _ScannerOverlayPainter(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cadre de scan (style WhatsApp)
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Animation de scan
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeInOut,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.3),
                                      primaryColor,
                                      primaryColor.withOpacity(0.3),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Instructions
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Positionnez le QR code dans le cadre',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'La détection est automatique',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Indicateur de chargement
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                              strokeWidth: 3,
                            ),
                            Icon(
                              Icons.qr_code_scanner,
                              color: primaryColor,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Traitement en cours...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Instructions de scan',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInfoItem(
                Icons.camera_alt,
                '1. Placez le QR code',
                'Dans le cadre de scan',
              ),
              _buildInfoItem(
                Icons.auto_awesome,
                '2. Attendez la détection',
                'Scannage automatique',
              ),
              _buildInfoItem(
                Icons.timer,
                '3. Validation rapide',
                'Pointage automatique',
              ),
              _buildInfoItem(
                Icons.security,
                '4. Sécurisé',
                'Vérification automatique',
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mediumGray),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCodeDetect(BarcodeCapture capture) async {
    if (isScanning || _isLoading) {
      _log('Scan déjà en cours, ignoré', level: 'WARNING');
      return;
    }
    if (capture.barcodes.isEmpty) {
      _log('Aucun QR code détecté', level: 'INFO');
      return;
    }

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) {
      _log('QR code sans valeur', level: 'WARNING');
      return;
    }

    _log('QR Code détecté!', level: 'SCAN');
    _log('Valeur brute: ${barcode.rawValue}', level: 'DEBUG');

    if (widget.back) {
      _log('Mode retour actif, renvoi immédiat de la valeur brute', level: 'INFO');
      Navigator.of(context).pop(barcode.rawValue);
      return;
    }

    try {
      isScanning = true;
      setState(() => _isLoading = true);
      _log('Début traitement QR code', level: 'INFO');

      // Arrêter temporairement le scanner
      cameraController.stop();
      _log('Scanner arrêté temporairement', level: 'INFO');

      // Décoder les données du QR code
      _log('Tentative de décodage JSON...', level: 'DEBUG');
      final qrData = json.decode(barcode.rawValue!);
      _log('QR code décodé avec succès', level: 'SUCCESS');
      _log('Données QR: $qrData', level: 'DEBUG');

      // Vérifier l'expiration
      final expiresAtStr = qrData['expires_at'] ?? '';
      if (expiresAtStr.isEmpty) {
        _log('Champ expires_at manquant', level: 'ERROR');
        _showErrorPopup('QR code invalide: champ expires_at manquant');
        return;
      }

      final expiresAt = DateTime.parse(expiresAtStr);
      final now = DateTime.now();
      _log('Expiration: $expiresAt', level: 'INFO');

      if (now.isAfter(expiresAt)) {
        _log('QR code expiré', level: 'WARNING');
        _showErrorPopup('QR code expiré! Veuillez scanner un nouveau code.');
        return;
      }
      _log('QR code valide (non expiré)', level: 'SUCCESS');

      // Vérifier l'autorisation (matricules)
      if (_userMatricule == null) {
        _log('Matricule utilisateur null', level: 'ERROR');
        _showErrorPopup('Matricule utilisateur non disponible');
        return;
      }

      final allowedMatricules = List<String>.from(qrData['matricules'] ?? []);
      _log('Matricules autorisés: $allowedMatricules', level: 'DEBUG');

      final userMatriculeClean = _userMatricule!.trim();
      _log('Matricule utilisateur nettoyé: "$userMatriculeClean"',
          level: 'DEBUG');

      bool isAuthorized = false;
      for (var mat in allowedMatricules) {
        final matClean = mat.trim();
        if (matClean == userMatriculeClean) {
          isAuthorized = true;
          break;
        }
      }

      if (!isAuthorized) {
        _log('Utilisateur non autorisé', level: 'WARNING');
        _showErrorPopup('Vous n\'êtes pas autorisé à pointer avec ce QR code');
        return;
      }
      _log('Utilisateur autorisé', level: 'SUCCESS');

      // Envoyer le pointage à l'API (sans justificatif)
      await _sendPointageToAPI(userMatriculeClean, null);
    } catch (e) {
      _log('Erreur traitement QR: $e', level: 'ERROR');
      _log('Stack trace: ${e.toString()}', level: 'ERROR');

      if (e is FormatException) {
        _log('FormatException - JSON invalide?', level: 'ERROR');
        _showErrorPopup('QR code invalide - format incorrect');
      } else if (e is NoSuchMethodError) {
        _log('NoSuchMethodError - Structure QR invalide', level: 'ERROR');
        _showErrorPopup('QR code invalide - structure incorrecte');
      } else {
        _showErrorPopup('Erreur de traitement: ${e.toString()}');
      }

      setState(() => _isLoading = false);
      isScanning = false;
      cameraController.start();
    }
  }

  Future<void> _sendPointageToAPI(
      String matricule, String? justificatif) async {
    _log(
        'Envoi pointage à l\'API... ${justificatif != null ? "avec justificatif" : "sans justificatif"}',
        level: 'INFO');

    final url = '${dotenv.get('API_URL')}/scan-emargement';
    _log('URL API: $url', level: 'DEBUG');

    final Map<String, dynamic> requestData = {
      'matricule': matricule,
    };

    if (justificatif != null && justificatif.isNotEmpty) {
      requestData['justificatif'] = justificatif;
    }

    _log('Données envoyées: $requestData', level: 'DEBUG');

    try {
      final startTime = DateTime.now();
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (_userToken != null) {
        headers['Authorization'] = 'Bearer $_userToken';
      }

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(requestData),
          )
          .timeout(const Duration(seconds: 30));

      final duration = DateTime.now().difference(startTime);
      _log('Réponse API reçue en ${duration.inMilliseconds}ms', level: 'INFO');
      _log('Status code: ${response.statusCode}', level: 'DEBUG');
      _log('Body: ${response.body}', level: 'DEBUG');

      final result = json.decode(response.body);
      final responseCode = result['code'] ?? 0;
      final message = result['message'] ?? 'Pas de message';
      final justificationRequired = result['justification_required'] ?? false;
      final avecJustificatif = result['avec_justificatif'] ?? false;
      final data = result['data'];
      final estEnRetard = data != null && data['est_en_retard'] == true;
      final estDepartAnticipe =
          data != null && data['est_depart_anticipe'] == true;

      _log('Code réponse: $responseCode, Message: $message', level: 'INFO');
      _log(
          'Avec justificatif: $avecJustificatif, En retard: $estEnRetard, Départ anticipé: $estDepartAnticipe',
          level: 'INFO');

      if (responseCode == 200) {
        // Pointage réussi (avec ou sans justificatif)
        _log('Pointage réussi! $message', level: 'SUCCESS');

        // Déterminer le type de pointage pour adapter le popup
        final bool isDepart = message.contains('Au revoir') ||
            message.contains('Départ anticipé');
        final bool isAvecJustificatif = avecJustificatif;

        String prenomStr = _userPrenom ?? '';
        String nomStr = _userNom ?? '';
        String fullName = '$prenomStr $nomStr'.trim().toUpperCase();

        String popupTitle =
            isDepart ? 'AU REVOIR $fullName'.trim() : 'BIENVENUE $fullName'.trim();
        String popupSubtitle = '';

        if (isDepart) {
          if (isAvecJustificatif) {
            popupSubtitle = 'Départ anticipé enregistré avec justificatif';
          } else if (estDepartAnticipe) {
            popupSubtitle = 'Départ anticipé enregistré';
          } else {
            popupSubtitle = 'Départ enregistré - Bonne soirée';
          }
        } else {
          if (isAvecJustificatif) {
            popupSubtitle = 'Arrivée avec justificatif enregistrée';
          } else if (estEnRetard) {
            popupSubtitle = 'Arrivée en retard enregistrée';
          } else {
            popupSubtitle = 'Arrivée à l\'heure enregistrée';
          }
        }

        // Si nous avons un justificatif, nous sommes dans le dialogue de justificatif
        if (justificatif != null) {
          // Fermer le dialogue de justificatif si il est ouvert
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }

        // Afficher le popup de succès avec les bonnes infos
        _showSuccessPopup(message, popupTitle, popupSubtitle, isDepart);
      } else if (responseCode == 403 && justificationRequired) {
        // Retard ou départ anticipé détecté - besoin de justificatif
        _log('Retard/départ anticipé détecté, demande de justificatif',
            level: 'WARNING');
        _showJustificatifDialog(message, matricule);
      } else {
        // Autre erreur
        _log('Erreur pointage: $message (code: $responseCode)', level: 'ERROR');
        _showErrorPopup(message);
      }
    } on http.ClientException catch (e) {
      _log('ClientException: $e', level: 'ERROR');
      _showErrorPopup('Erreur réseau: ${e.message}');
    } on FormatException catch (e) {
      _log('FormatException (JSON invalide): $e', level: 'ERROR');
      _showErrorPopup('Erreur de format de réponse serveur');
    } on Exception catch (e) {
      _log('Exception inconnue: $e', level: 'ERROR');
      _showErrorPopup('Erreur inattendue: ${e.toString()}');
    } finally {
      // Toujours réinitialiser l'état de chargement
      if (mounted) {
        setState(() => _isLoading = false);
      }
      isScanning = false;

      // Redémarrer le scanner seulement si nous ne sommes pas dans un dialogue
      if (justificatif != null || !_isLoading) {
        cameraController.start();
      }
    }
  }

  void _showSuccessPopup(
      String message, String title, String subtitle, bool isDepart) {
    _log('Affichage popup de succès', level: 'SUCCESS');
    _animationController.reset();
    _animationController.forward();

    // Choisir l'emoji et le gradient selon le type de pointage
    String emoji = isDepart ? '👋' : '🎉';
    Color gradientStart = isDepart ? Color(0xFF4A90E2) : successGradientStart;
    Color gradientEnd = isDepart ? Color(0xFF9013FE) : successGradientEnd;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [gradientStart, gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: gradientEnd.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animation de cercle de succès
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.6),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Emoji dynamique
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Titre animé (Arrivée/Départ)
                          AnimatedOpacity(
                            opacity:
                                _animationController.value > 0.5 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(
                                  0, _animationController.value > 0.5 ? 0 : 20),
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Sous-titre (type de pointage)
                          AnimatedOpacity(
                            opacity:
                                _animationController.value > 0.6 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(
                                  0, _animationController.value > 0.6 ? 0 : 20),
                              child: Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Message de l'API
                          AnimatedOpacity(
                            opacity:
                                _animationController.value > 0.7 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(
                                  0, _animationController.value > 0.7 ? 0 : 20),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Bouton avec animation
                          AnimatedOpacity(
                            opacity:
                                _animationController.value > 0.9 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(
                                  0, _animationController.value > 0.9 ? 0 : 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _animationController.reverse().then((_) {
                                      Navigator.of(ctx).pop();
                                      if (widget.back) {
                                        Navigator.of(context)
                                            .pop('pointage_reussi');
                                      }
                                      // Redémarrer le scanner
                                      setState(() {
                                        _isLoading = false;
                                        isScanning = false;
                                      });
                                      cameraController.start();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: gradientEnd,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    isDepart ? 'OK' : 'CONTINUER',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            );
          },
        );
      },
    );
  }

  void _showErrorPopup(String message) {
    _log('Affichage popup d\'erreur', level: 'ERROR');
    _animationController.reset();
    _animationController.forward();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      barrierDismissible: false,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [errorGradientStart, errorGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: errorGradientEnd.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animation d'émoji de mécontentement
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.9),
                                      Colors.white.withOpacity(0.6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              // Gros émoji moderne de mécontentement
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '😞',
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Titre
                          AnimatedOpacity(
                            opacity:
                                _animationController.value > 0.5 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(
                                  0, _animationController.value > 0.5 ? 0 : 20),
                              child: Text(
                                'ERREUR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Message
                          AnimatedOpacity(
                            opacity:
                                _animationController.value > 0.7 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(
                                  0, _animationController.value > 0.7 ? 0 : 20),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Boutons
                          AnimatedOpacity(
                            opacity:
                                _animationController.value > 0.9 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(
                                  0, _animationController.value > 0.9 ? 0 : 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _animationController
                                              .reverse()
                                              .then((_) {
                                            Navigator.of(ctx).pop();
                                            // Redémarrer le scanner
                                            setState(() {
                                              _isLoading = false;
                                              isScanning = false;
                                            });
                                            cameraController.start();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: errorGradientEnd,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: const Text(
                                          'RÉESSAYER',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
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
              ),
            );
          },
        );
      },
    );
  }

  void _showJustificatifDialog(String message, String matricule) {
    _log('Affichage dialogue justificatif', level: 'INFO');
    _justificatifController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          bool isSubmitting = false;

          Future<void> _submitJustificatif() async {
            final justificatif = _justificatifController.text.trim();
            if (justificatif.isEmpty) {
              _log('Justificatif vide', level: 'WARNING');
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('Veuillez saisir un justificatif'),
                  backgroundColor: errorColor,
                ),
              );
              return;
            }

            _log('Justificatif saisi: "$justificatif"', level: 'INFO');
            _log('Envoi pointage avec justificatif...', level: 'INFO');

            setStateDialog(() => isSubmitting = true);

            try {
              await _sendPointageToAPI(matricule, justificatif);
              // Ne pas fermer ici - la méthode _sendPointageToAPI le fera après succès
            } catch (e) {
              setStateDialog(() => isSubmitting = false);
              _log('Erreur lors de l\'envoi: $e', level: 'ERROR');
            }
          }

          return Dialog(
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
                  // Icône d'avertissement
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: warningColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: warningColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Titre
                  Text(
                    message.contains('Retard')
                        ? 'Retard détecté'
                        : 'Départ anticipé',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Message de l'API
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Champ de saisie du justificatif
                  Text(
                    'Veuillez saisir votre justificatif :',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _justificatifController,
                    maxLines: 3,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      hintText: 'Saisissez votre justificatif ici...',
                      hintStyle: TextStyle(color: mediumGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: mediumGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: mediumGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Boutons
                  if (isSubmitting)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Envoi en cours...',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _log('Annulation pointage avec justificatif',
                                  level: 'INFO');
                              Navigator.of(ctx).pop();
                              setState(() {
                                _isLoading = false;
                                isScanning = false;
                              });
                              cameraController.start();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: mediumGray),
                            ),
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitJustificatif,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Envoyer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('Build de l\'écran de scan', level: 'INFO');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildScannerView(),
            _buildInfoPanel(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _log('Dispose de l\'écran de scan', level: 'INFO');
    _animationController.dispose();
    cameraController.dispose();
    _justificatifController.dispose();
    super.dispose();
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Cadre de scan (zone transparente)
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    // Créer un trou au centre
    path.addRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
    );
    path.fillType = PathFillType.evenOdd;

    // Dessiner l'overlay sombre
    canvas.drawPath(path, paint..color = Colors.black.withOpacity(0.6));

    // Dessiner le cadre de scan (style WhatsApp)
    final framePaint = Paint()
      ..color = Color(0xFFF77F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = Color(0xFFF77F00)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Coin supérieur gauche
    canvas.drawLine(
      scanArea.topLeft,
      scanArea.topLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.topLeft,
      scanArea.topLeft + Offset(0, cornerLength),
      cornerPaint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      scanArea.topRight,
      scanArea.topRight - Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.topRight,
      scanArea.topRight + Offset(0, cornerLength),
      cornerPaint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      scanArea.bottomLeft,
      scanArea.bottomLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.bottomLeft,
      scanArea.bottomLeft - Offset(0, cornerLength),
      cornerPaint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      scanArea.bottomRight,
      scanArea.bottomRight - Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.bottomRight,
      scanArea.bottomRight - Offset(0, cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
