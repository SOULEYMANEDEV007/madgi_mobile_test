import 'dart:async';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Acceuil extends StatefulWidget {
  const Acceuil({super.key});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);

  late String _currentDate;
  late String _currentTime;
  late String _currentDay;
  String _qrCodeData = "";
  late Timer _timer;
  var userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDateTime();
    _getUserInfo();
    _startTimers();
  }

  void _initDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentDate = DateFormat('dd MMMM yyyy', 'fr_FR').format(now);
      _currentTime = DateFormat('HH:mm', 'fr_FR').format(now);
      _currentDay = DateFormat('EEEE', 'fr_FR').format(now);
    });
  }

  Future<void> _getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };
      var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/user-info'));
      request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      if (decode['success']) {
        setState(() {
          userInfo = decode['data']['user'];
        });
        await _updateQRCodeData();
      }
    } catch (e) {
      print('❌ Erreur chargement infos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startTimers() {
    // Mettre à jour l'heure chaque minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateDateTime();
    });

    // Mettre à jour le QR code toutes les 30 secondes
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateQRCodeData();
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm', 'fr_FR').format(now);
    });
  }

  Future<void> _updateQRCodeData() async {
    if (userInfo == null) return;

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;

      setState(() {
        _qrCodeData = json.encode({
          "matricule": userInfo['matricule'] ?? '',
          "nom": userInfo['nom'] ?? '',
          "date": _currentDate,
          "heure": _currentTime,
          "device_id": deviceInfo.id,
          "timestamp": DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      print('❌ Erreur génération QR code: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
        children: [
          // Date et heure
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentDay,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_currentDate • $_currentTime',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'EN LIGNE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Informations utilisateur
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                ),
                child: userInfo != null && userInfo['photo'] != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage('https://rh.madgi.ci/${userInfo['photo']}'),
                )
                    : Icon(
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
                      'Bonjour,',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      userInfo != null ? userInfo['nom'] ?? 'Chargement...' : 'Chargement...',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titre
          Text(
            'Votre code d\'émargement',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            'Présentez ce code QR pour pointer',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: mediumGray, width: 1),
            ),
            child: Column(
              children: [
                if (_isLoading)
                  Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                else if (_qrCodeData.isNotEmpty && userInfo != null)
                  Column(
                    children: [
                      QrImageView(
                        data: _qrCodeData,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: primaryColor,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.autorenew,
                              color: primaryColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Actualisé toutes les 30 secondes',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: mediumGray,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Génération du code...',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Informations de session
          if (userInfo != null && !_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mediumGray, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.badge,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Matricule',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          userInfo['matricule'] ?? 'Non disponible',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified,
                    color: secondaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: mediumGray, width: 1),
            ),
            child: Column(
              children: [
                _buildInstructionStep(
                  number: 1,
                  icon: Icons.qr_code_scanner,
                  title: 'Présentez le code QR',
                  description: 'Montrez ce code à la tablette de pointage',
                ),
                const SizedBox(height: 16),
                _buildInstructionStep(
                  number: 2,
                  icon: Icons.verified,
                  title: 'Validation automatique',
                  description: 'La détection est instantanée',
                ),
                const SizedBox(height: 16),
                _buildInstructionStep(
                  number: 3,
                  icon: Icons.notifications,
                  title: 'Confirmation',
                  description: 'Recevez une notification de confirmation',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({
    required int number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildQRCodeSection(),
                    const SizedBox(height: 24),
                    _buildInstructions(),
                    const SizedBox(height: 40),
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