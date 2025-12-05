import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Resultat extends StatefulWidget {
  final scanResult;

  const Resultat({super.key, required this.scanResult});

  @override
  State<Resultat> createState() => _ResultatState();
}

class _ResultatState extends State<Resultat> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);

  bool _isLoading = true;
  bool _isSuccess = false;
  bool _isExpired = false;
  bool _isError = false;
  String _statusText = 'Vérification en cours...';
  String _detailText = '';
  var userInfo;
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    _processScanResult();
  }

  Future<void> _processScanResult() async {
    try {
      final scanData = json.decode(widget.scanResult);

      // Vérifier si le code a expiré
      if (scanData['Time'] != null) {
        final specificTime = scanData['Time'];
        final timeParts = specificTime.split(':');
        final now = DateTime.now();

        if (timeParts.length >= 2) {
          final specificDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]) + 5,
          );

          final difference = specificDateTime.difference(now);

          if (difference.isNegative) {
            _setResultState(
              isSuccess: false,
              isExpired: true,
              statusText: 'Code expiré',
              detailText: 'Le code QR a expiré. Veuillez scanner un nouveau code.',
            );
            return;
          }
        }
      }

      // Récupérer les infos utilisateur
      final prefs = await SharedPreferences.getInstance();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };

      final userRequest = http.Request(
        'GET',
        Uri.parse('https://rh.madgi.ci/api/v1/user-info'),
      );

      userRequest.body = json.encode({
        'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'
      });
      userRequest.headers.addAll(headers);

      final userResponse = await userRequest.send();
      final userData = await userResponse.stream.bytesToString();
      final userDecode = json.decode(userData);

      if (userDecode['success']) {
        setState(() => userInfo = userDecode['data']['user']);
        await _sendRegistration(scanData, prefs);
      } else {
        _setResultState(
          isSuccess: false,
          isError: true,
          statusText: 'Erreur',
          detailText: 'Impossible de récupérer vos informations.',
        );
      }
    } catch (e) {
      _setResultState(
        isSuccess: false,
        isError: true,
        statusText: 'Erreur',
        detailText: 'Une erreur est survenue lors du traitement.',
      );
    }
  }

  Future<void> _sendRegistration(Map<String, dynamic> scanData, SharedPreferences prefs) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };

      final request = http.Request(
        'POST',
        Uri.parse('https://rh.madgi.ci/api/v1/register'),
      );

      request.body = json.encode({
        'date': scanData['Date'],
        'time': scanData['Time'],
        'matricule': userInfo['matricule'],
        'type_device': 'Mobile Device',
        'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'
      });

      request.headers.addAll(headers);

      final response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      if (decode['code'] == 200) {
        _setResultState(
          isSuccess: true,
          statusText: 'Émargement réussi',
          detailText: 'Votre pointage a été enregistré avec succès.',
        );

        // Auto-navigation après 3 secondes
        _autoNavigateTimer = Timer(const Duration(seconds: 3), () {
          _navigateToHome();
        });
      } else {
        _setResultState(
          isSuccess: false,
          isError: true,
          statusText: 'Erreur d\'enregistrement',
          detailText: decode['message'] ?? 'Impossible d\'enregistrer le pointage.',
        );
      }
    } catch (e) {
      _setResultState(
        isSuccess: false,
        isError: true,
        statusText: 'Erreur réseau',
        detailText: 'Vérifiez votre connexion internet.',
      );
    }
  }

  void _setResultState({
    required bool isSuccess,
    bool isExpired = false,
    bool isError = false,
    required String statusText,
    required String detailText,
  }) {
    setState(() {
      _isLoading = false;
      _isSuccess = isSuccess;
      _isExpired = isExpired;
      _isError = isError;
      _statusText = statusText;
      _detailText = detailText;
    });
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
          Text(
            'Résultat du scan',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérification de votre pointage',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              Icon(
                Icons.qr_code_scanner,
                color: primaryColor,
                size: 30,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _statusText,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Veuillez patienter...',
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: successColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: successColor.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Icon(
            Icons.check_circle,
            color: successColor,
            size: 60,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _statusText,
          style: TextStyle(
            color: successColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _detailText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (userInfo != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mediumGray),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  color: primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  userInfo['nom'] ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.badge,
                  color: primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  userInfo['matricule'] ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text(
          'Redirection automatique dans 3 secondes...',
          style: TextStyle(
            color: textColor.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: errorColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: errorColor.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Icon(
            _isExpired ? Icons.timer_off : Icons.error_outline,
            color: errorColor,
            size: 60,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _statusText,
          style: TextStyle(
            color: errorColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _detailText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          if (!_isLoading)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _navigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (_isError || _isExpired)
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Retour au scan
                },
                child: Text(
                  'Essayer à nouveau',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    if (_autoNavigateTimer?.isActive ?? false) {
      _autoNavigateTimer!.cancel();
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
    super.dispose();
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
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
                          if (_isLoading)
                            _buildLoadingState()
                          else if (_isSuccess)
                            _buildSuccessState()
                          else
                            _buildErrorState(),

                          _buildActionButtons(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informations de débogage (optionnel)
                    if (!_isLoading && _isError)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mediumGray),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Informations techniques',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Code scanné: ${widget.scanResult.length > 100 ? '${widget.scanResult.substring(0, 100)}...' : widget.scanResult}',
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

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

  static const Color mediumGray = Color(0xFFE2E8F0);
}