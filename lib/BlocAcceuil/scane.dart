import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // ou qr_code_scanner
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Scane extends StatefulWidget {
  final bool back;
  const Scane({super.key, this.back = false});

  @override
  State<Scane> createState() => _ScaneState();
}

class _ScaneState extends State<Scane> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  // Fonction pour envoyer le pointage à l'API
  Future<void> _sendPointageToAPI(String matricule, Map<String, dynamic> qrData) async {
    try {
      print('📤 Envoi pointage pour matricule: $matricule');
      print('🔑 Session ID: ${qrData['session_id']}');

      final response = await http.post(
        Uri.parse('https://votre-domaine.com/api/v1/scan-emargement'),
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
      print('📥 Message: ${result['message']}');

      if (result['code'] == 200) {
        // Succès
        _showSuccessDialog(context, result['message']);
      } else {
        // Erreur
        _showErrorDialog(context, result['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      print('❌ Erreur API: $e');
      _showErrorDialog(context, 'Erreur réseau: $e');
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Succès'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.back) {
                Navigator.of(context).pop('pointage_reussi');
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Redémarrer le scanner après erreur
              isScanning = false;
              cameraController.start();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.back,
        leading: widget.back
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
        title: const Text('Scanner QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) async {
                if (!isScanning && capture.barcodes.isNotEmpty) {
                  isScanning = true;
                  final barcode = capture.barcodes.first;

                  if (barcode.rawValue != null) {
                    print('🔍 QR Code scanné: ${barcode.rawValue}');

                    try {
                      // 1. Décoder les données du QR code
                      final qrData = json.decode(barcode.rawValue!);

                      // 2. Vérifier si la session est expirée
                      final expiresAt = DateTime.parse(qrData['expires_at']);
                      if (DateTime.now().isAfter(expiresAt)) {
                        _showErrorDialog(context, 'QR code expiré! Veuillez scanner un nouveau code.');
                        return;
                      }

                      // 3. Récupérer le matricule de l'utilisateur connecté
                      final prefs = await SharedPreferences.getInstance();
                      final userInfoString = prefs.getString('userInfo');

                      if (userInfoString == null) {
                        _showErrorDialog(context, 'Utilisateur non connecté');
                        return;
                      }

                      final userInfo = json.decode(userInfoString);
                      final userMatricule = userInfo['user']['matricule'];

                      // 4. Vérifier si le matricule est autorisé dans ce QR code
                      final allowedMatricules = List<String>.from(qrData['matricules'] ?? []);
                      if (!allowedMatricules.contains(userMatricule)) {
                        _showErrorDialog(context, 'Vous n\'êtes pas autorisé à pointer avec ce QR code');
                        return;
                      }

                      // 5. Arrêter le scanner temporairement
                      cameraController.stop();

                      // 6. Envoyer le pointage à l'API
                      await _sendPointageToAPI(userMatricule, qrData);

                    } catch (e) {
                      print('❌ Erreur traitement QR: $e');
                      _showErrorDialog(context, 'QR code invalide: $e');
                      isScanning = false;
                      cameraController.start();
                    }
                  }
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black.withOpacity(0.7),
            child: const Column(
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '1. Placez le QR code dans le cadre\n'
                      '2. Le scan sera automatique\n'
                      '3. Attendez la confirmation',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}