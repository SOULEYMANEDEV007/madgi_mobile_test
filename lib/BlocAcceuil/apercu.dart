import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:madgi_mobile/BlocAcceuil/informations.dart';
import 'package:madgi_mobile/BlocAcceuil/notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class Apercu extends StatefulWidget {
  final title;
  final data;
  const Apercu({super.key, required this.data, this.title});

  @override
  State<Apercu> createState() => _ApercuState();
}

class _ApercuState extends State<Apercu> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF38A169);

  bool _isDownloading = false;

  Future<void> markAsRead(id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };
      var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/info/$id'));
      request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);
      print(decode);
    } catch (e) {
      print('❌ Erreur marquage lu: $e');
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    try {
      setState(() => _isDownloading = true);
      await requestStoragePermission();
      Directory? downloadDir = await getDownloadDirectory();
      if (downloadDir == null) {
        throw Exception('Impossible d\'accéder au répertoire de téléchargement');
      }

      String downloadPath = downloadDir.path;
      Dio dio = Dio();

      // Ajouter un nom de fichier plus descriptif
      final fileExtension = p.extension(url);
      final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
      final fullFileName = '$cleanFileName$fileExtension';

      await dio.download(url, '$downloadPath/$fullFileName');
      _showSuccessDialog('Fichier téléchargé avec succès', 'Vérifiez votre dossier de téléchargements');
    } catch (e) {
      print('❌ Erreur téléchargement: $e');
      _showErrorDialog('Erreur lors du téléchargement');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Widget _buildFilePreview(String filePath) {
    String extension = p.extension(filePath).toLowerCase();
    final fullUrl = "https://rh.madgi.ci/$filePath";

    if (extension == '.pdf') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mediumGray, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    color: primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isDownloading
                  ? null
                  : () => downloadFile(fullUrl, 'Document_${widget.data['info']['title'] ?? 'MADGI'}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isDownloading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Télécharger',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (['.png', '.jpg', '.jpeg', '.gif', '.bmp'].contains(extension)) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showImageViewer(context, Image.network(fullUrl).image,
                  backgroundColor: Colors.black,
                  onViewerDismissed: () {},
                );
              },
              child: Container(
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: lightGray,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: lightGray,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: mediumGray,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image non disponible',
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isDownloading
                  ? null
                  : () => downloadFile(fullUrl, 'Image_${widget.data['info']['title'] ?? 'MADGI'}'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: primaryColor),
              ),
              child: _isDownloading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Télécharger l\'image',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mediumGray, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: mediumGray,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    extension.replaceAll('.', '').toUpperCase(),
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isDownloading
                  ? null
                  : () => downloadFile(fullUrl, 'Fichier_${widget.data['info']['title'] ?? 'MADGI'}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isDownloading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Télécharger le fichier',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<Directory?> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();
      }
    }
  }

  void _showSuccessDialog(String title, String message) {
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
                title,
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
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
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
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Information',
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
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
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
    if (widget.data['info']['id'] != null) {
      markAsRead(widget.data['info']['id']);
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
                      builder: (context) => widget.title == 'notification'
                          ? const Notifications()
                          : const Informations(),
                    ),
                  );
                },
              ),
              Expanded(
                child: Text(
                  'Détails',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          if (widget.data['info']['title'] != null)
            Text(
              widget.data['info']['title'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: mediumGray, width: 1),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contenu de la note
                    _buildContentCard(
                      'Note de service',
                      widget.data['info']['content'] ?? '',
                    ),

                    // Fichier joint
                    if (widget.data['media'] != null && widget.data['media']['src'] != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fichier joint',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: mediumGray, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _buildFilePreview(widget.data['media']['src']),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Informations émetteur
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Émetteur de la note',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mediumGray, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildInfoItem(
                                  'Nom & prénom:',
                                  widget.data['info']['post_name'] ?? 'Non spécifié',
                                ),
                                const Divider(color: mediumGray, height: 20),
                                _buildInfoItem(
                                  'Téléphone:',
                                  widget.data['info']['post_phone'] ?? 'Non spécifié',
                                ),
                                const Divider(color: mediumGray, height: 20),
                                _buildInfoItem(
                                  'Poste:',
                                  widget.data['departement'] ?? 'Non spécifié',
                                ),
                              ],
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
}