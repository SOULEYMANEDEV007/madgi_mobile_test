// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  var back;
  ProfileScreen({Key? key, this.back = false}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF38A169);

  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController motdepasseTextEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController nom = TextEditingController();
  TextEditingController matricule = TextEditingController();
  TextEditingController tel = TextEditingController();
  TextEditingController email = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  bool _isSaving = false;
  var userInfo;
  XFile? _selectedImage;

  Future<void> getUserInfo() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };
      var request = http.Request('GET', Uri.parse('http://192.168.1.12:8000/api/v1/user-info'));
      request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);
      if (decode['success']) {
        setState(() => userInfo = decode['data']['user']);
        nom.text = userInfo['nom'] ?? '';
        matricule.text = userInfo['matricule'] ?? '';
        tel.text = userInfo['tel'] ?? '';
        email.text = userInfo['email'] ?? '';
      }
    } catch (e) {
      print('❌ Erreur chargement infos: $e');
    } finally {
      setState(() => _isLoading = false);
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
                  'Mon profil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Pour centrer le titre
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gérez vos informations personnelles',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final hasPhoto = userInfo != null && userInfo['photo'] != null;
    final hasSelectedImage = _selectedImage != null;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
                  : hasSelectedImage
                  ? Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
              )
                  : hasPhoto
                  ? Image.network(
                'https://rh.madgi.ci/${userInfo['photo']}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: lightGray,
                    child: Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 48,
                    ),
                  );
                },
              )
                  : Container(
                color: lightGray,
                child: Icon(
                  Icons.person,
                  color: primaryColor,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller, {
        bool isPassword = false,
        bool enabled = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            obscureText: isPassword && _obscureText,
            keyboardType: keyboardType,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : lightGray,
              hintText: hint,
              hintStyle: TextStyle(color: mediumGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: mediumGray, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: mediumGray, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: mediumGray,
                ),
                onPressed: _togglePasswordVisibility,
              )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 24),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _selectedImage = pickedFile);
        await _uploadImage();
      }
    } catch (e) {
      print('❌ Erreur sélection image: $e');
      _showMessageDialog('Erreur', 'Impossible de sélectionner l\'image');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      setState(() => _isSaving = true);

      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.12:8000/api/v1/update-user'),
      );

      request.fields.addAll({
        'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'
      });

      request.files.add(await http.MultipartFile.fromPath(
        'picture',
        _selectedImage!.path,
      ));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      if (decode['success']) {
        setState(() => userInfo = decode['data']['user']);
        _showMessageDialog('Succès', 'Photo mise à jour avec succès');
      } else {
        _showMessageDialog('Erreur', decode['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      print('❌ Erreur upload image: $e');
      _showMessageDialog('Erreur', 'Erreur réseau lors de l\'upload');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSaving = true);

      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.12:8000/api/v1/update-user'),
      );

      request.fields.addAll({
        'nom': nom.text,
        'tel': tel.text,
        'email': email.text,
        'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'
      });

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'picture',
          _selectedImage!.path,
        ));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      if (decode['success']) {
        setState(() => userInfo = decode['data']['user']);
        _showSuccessDialog('Profil mis à jour avec succès');
      } else {
        _showMessageDialog('Erreur', decode['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      _showMessageDialog('Erreur', 'Erreur réseau lors de la mise à jour');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showSuccessDialog(String message) {
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
                  onPressed: () => Navigator.of(ctx).pop(),
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

  void _showMessageDialog(String title, String message) {
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
              Icon(
                title == 'Succès' ? Icons.check_circle : Icons.error_outline,
                color: title == 'Succès' ? successColor : primaryColor,
                size: 48,
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
    getUserInfo();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildProfileImage(),
                      const SizedBox(height: 8),
                      if (userInfo != null)
                        Text(
                          userInfo['nom'] ?? '',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (userInfo != null)
                        Text(
                          userInfo['matricule'] ?? '',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),

                      _buildSection('Informations personnelles'),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildTextField(
                              'Nom complet',
                              'Votre nom et prénom',
                              nom,
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Matricule',
                              'Votre numéro de matricule',
                              matricule,
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Numéro de téléphone',
                              'Votre numéro de téléphone',
                              tel,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Adresse email',
                              'Votre adresse email',
                              email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Enregistrer les modifications',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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