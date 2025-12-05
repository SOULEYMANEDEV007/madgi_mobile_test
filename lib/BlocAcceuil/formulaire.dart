// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, unused_field, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Formulaire extends StatefulWidget {
  final typeId;
  const Formulaire({Key? key, required this.typeId}) : super(key: key);

  @override
  _FormulaireState createState() => _FormulaireState();
}

class _FormulaireState extends State<Formulaire> {
  // Couleurs officielles
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color errorColor = Color(0xFFE53E3E);

  TextEditingController nomprenomTextEditingController = TextEditingController();
  TextEditingController matriculeTextEditingController = TextEditingController();
  TextEditingController departementTextEditingController = TextEditingController();
  TextEditingController serviceTextEditingController = TextEditingController();
  TextEditingController datedebutTextEditingController = TextEditingController();
  TextEditingController datefinTextEditingController = TextEditingController();
  TextEditingController lieuTextEditingController = TextEditingController();
  TextEditingController callUser = TextEditingController();
  TextEditingController interim = TextEditingController();
  TextEditingController contactTextEditingController = TextEditingController();
  TextEditingController motdepasseTextEditingController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  var userInfo;
  int _departement = 0;
  int _service = 0;
  List _departements = [];
  List _services = [];

  Future getUserInfo() async {
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
    if (decode['success']) setState(() {
      userInfo = decode['data']['user'];
      nomprenomTextEditingController.text = userInfo['nom'];
      matriculeTextEditingController.text = userInfo['matricule'];
    });
  }

  Future getDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.Request('GET', Uri.parse('http://192.168.1.12:8000/api/v1/departments'));
    request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    if (decode['success']) setState(() => _departements = decode['data']);
  }

  Future getServices() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.Request('GET', Uri.parse('http://192.168.1.12:8000/api/v1/services'));
    request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    if (decode['success']) setState(() => _services = decode['data']);
  }

  @override
  void initState() {
    super.initState();
    getDepartments();
    getServices();
    getUserInfo();
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
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Formulaire de demande',
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
            'Remplissez tous les champs pour soumettre votre demande',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 48, // 24 padding de chaque côté
          ),
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
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: isPassword && _obscureText,
            keyboardType: label.contains('Téléphone') ? TextInputType.phone : TextInputType.text,
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
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List items) {
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 48, // 24 padding de chaque côté
          ),
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
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            items: items.map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value['name'],
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 100, // Contrainte pour le texte
                  ),
                  child: Text(
                    value['name'],
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                controller.text = newValue;
                final result = items.firstWhere(
                      (element) => element['name'] == newValue,
                  orElse: () => {'id': -1},
                );
                if (result['id'] != -1) {
                  if (label == 'Département') {
                    setState(() => _departement = result['id']);
                  } else {
                    setState(() => _service = result['id']);
                  }
                }
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
              hintText: 'Sélectionnez un $label',
              hintStyle: TextStyle(
                color: mediumGray,
                fontSize: 14,
              ),
            ),
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hint, TextEditingController controller) {
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 48,
          ),
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
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: primaryColor,
                        onPrimary: Colors.white,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                });
              }
            },
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
              suffixIcon: Icon(Icons.calendar_today, color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: secondaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Demande envoyée !',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre demande a été soumise avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/valider');
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
                  color: textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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

  Future _valider() async {
    if (_isLoading) return;

    final nomprenom = nomprenomTextEditingController.text;
    final matricule = matriculeTextEditingController.text;
    final departement = departementTextEditingController.text;
    final service = serviceTextEditingController.text;
    final datedebut = datedebutTextEditingController.text;
    final datefin = datefinTextEditingController.text;
    final lieu = lieuTextEditingController.text;
    final contact = contactTextEditingController.text;

    // Validation des champs requis
    if (nomprenom.isEmpty ||
        matricule.isEmpty ||
        departement.isEmpty ||
        service.isEmpty ||
        datedebut.isEmpty ||
        datefin.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs obligatoires.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };

      var request = http.Request('POST', Uri.parse('http://192.168.1.12:8000/api/v1/leaves'));
      request.body = json.encode({
        "fullname": nomprenom,
        "matricule": matricule,
        "start_date": datedebut,
        "end_date": datefin,
        "place_enjoyment": lieu,
        "call_user_name": callUser.text,
        "call_phone": contact,
        "interim": interim.text,
        "department_id": '$_departement',
        "service_id": '$_service',
        "type_id": '${widget.typeId}',
        'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'
      });

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);

      setState(() => _isLoading = false);

      if (decode['success']) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(decode['message'] ?? 'Une erreur est survenue');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Erreur de connexion. Veuillez réessayer.');
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section informations personnelles
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: Text(
                        'Informations personnelles',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildTextField('Nom et prénom', 'Saisissez votre nom complet',
                          nomprenomTextEditingController, enabled: false),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildTextField('Matricule', 'Votre matricule',
                          matriculeTextEditingController, enabled: false),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildDropdownField('Département', departementTextEditingController, _departements),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildDropdownField('Service', serviceTextEditingController, _services),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: Divider(color: mediumGray, height: 1),
                    ),
                    const SizedBox(height: 24),

                    // Section congé
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: Text(
                        'Détails du congé',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: (MediaQuery.of(context).size.width - 88) / 2, // 48 + 16 + 24 padding
                              ),
                              child: _buildDateField('Date de début', 'JJ/MM/AAAA', datedebutTextEditingController),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: (MediaQuery.of(context).size.width - 88) / 2,
                              ),
                              child: _buildDateField('Date de fin', 'JJ/MM/AAAA', datefinTextEditingController),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildTextField('Lieu de jouissance', 'Saisissez le lieu', lieuTextEditingController),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildTextField('Personne à contacter', 'Nom de la personne', callUser),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildTextField('Téléphone à contacter', 'Numéro de téléphone', contactTextEditingController),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: _buildTextField('Intérim', 'Nom de l\'intérimaire', interim),
                    ),
                    const SizedBox(height: 32),

                    // Bouton de soumission
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _valider,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
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
                              Icon(Icons.send, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Envoyer ma demande',
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
                    const SizedBox(height: 24),
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