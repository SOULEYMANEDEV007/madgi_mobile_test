import 'dart:convert';
import 'package:flutter/material.dart';
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

class _ScaneState extends State<Scane> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00); // Orange principal
  static const Color secondaryColor = Color(0xFF009A44); // Vert ivoirien
  static const Color backgroundColor = Color(0xFFFFFFFF); // Blanc
  static const Color textColor = Color(0xFF2D3748); // Gris foncé pour texte
  static const Color lightGray = Color(0xFFF7FAFC); // Gris très clair
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF38A169); // Vert succès
  static const Color errorColor = Color(0xFFE53E3E); // Rouge erreur

  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;
  bool _isLoading = false;
  bool _flashOn = false;
  String? _userMatricule;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('userInfo');

      if (userInfoString == null) return;

      final userInfo = json.decode(userInfoString);
      setState(() {
        _userMatricule = userInfo['user']['matricule']?.toString();
      });
    } catch (e) {
      print('❌ Erreur chargement infos: $e');
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
                onPressed: () => Navigator.of(context).pop(),
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
                'Valable 5 secondes',
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
    if (isScanning || _isLoading) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    print('🔍 QR Code scanné: ${barcode.rawValue}');

    try {
      isScanning = true;
      setState(() => _isLoading = true);

      // Arrêter temporairement le scanner
      cameraController.stop();

      // Décoder les données du QR code
      final qrData = json.decode(barcode.rawValue!);

      // Vérifier l'expiration
      final expiresAt = DateTime.parse(qrData['expires_at'] ?? DateTime.now().toIso8601String());
      if (DateTime.now().isAfter(expiresAt)) {
        _showErrorDialog('QR code expiré! Veuillez scanner un nouveau code.');
        return;
      }

      // Vérifier l'autorisation
      if (_userMatricule == null) {
        _showErrorDialog('Matricule utilisateur non disponible');
        return;
      }

      final allowedMatricules = List<String>.from(qrData['matricules'] ?? []);
      final userMatriculeClean = _userMatricule!.trim();
      final isAuthorized = allowedMatricules.any((mat) => mat.trim() == userMatriculeClean);

      if (!isAuthorized) {
        _showErrorDialog('Vous n\'êtes pas autorisé à pointer avec ce QR code');
        return;
      }

      // Envoyer le pointage à l'API
      await _sendPointageToAPI(userMatriculeClean, qrData);

    } catch (e) {
      print('❌ Erreur traitement QR: $e');
      _showErrorDialog('QR code invalide ou erreur de traitement');
    } finally {
      setState(() => _isLoading = false);
      isScanning = false;
      cameraController.start();
    }
  }

  Future<void> _sendPointageToAPI(String matricule, Map<String, dynamic> qrData) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9:8000/api/v1/scan-emargement'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'matricule': matricule,
          'session_id': qrData['session_id'],
          'scan_time': DateTime.now().toIso8601String(),
        }),
      );

      final result = json.decode(response.body);
      print('📥 Réponse API: ${response.statusCode}');

      if (result['code'] == 200) {
        _showSuccessDialog(result['message'] ?? 'Pointage enregistré avec succès');
      } else {
        _showErrorDialog(result['message'] ?? 'Erreur lors du pointage');
      }
    } catch (e) {
      print('❌ Erreur API: $e');
      _showErrorDialog('Erreur réseau: $e');
    }
  }

  void _showSuccessDialog(String message) {
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
                'Succès',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (widget.back) {
                      Navigator.of(context).pop('pointage_reussi');
                    }
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
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
                  color: errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: errorColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: mediumGray),
                      ),
                      child: Text(
                        'Fermer',
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
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _isLoading = false;
                          isScanning = false;
                        });
                        cameraController.start();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Réessayer',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    cameraController.dispose();
    super.dispose();
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

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