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
    var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/user-info'));
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
    var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/departments'));
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
    var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/services'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Formulaire de demande'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Nom et prénom', 'Cliquez pour saisir', nomprenomTextEditingController),
              const SizedBox(height: 15),
              _buildTextField('Matricule', 'Cliquez pour saisir', matriculeTextEditingController),
              const SizedBox(height: 15),
              _buildDropdownField('Département', departementTextEditingController, _departements),
              const SizedBox(height: 15),
              _buildDropdownField('Service', serviceTextEditingController, _services),
              const SizedBox(height: 15),
              _buildDateField('Date de début', 'Cliquez pour saisir', datedebutTextEditingController),
              const SizedBox(height: 15),
              _buildDateField('Date de fin', 'Cliquez pour saisir', datefinTextEditingController),
              const SizedBox(height: 15),
              _buildTextField('Lieu de jouissance', 'Cliquez pour saisir', lieuTextEditingController),
              const SizedBox(height: 15),
              _buildTextField('Personne à contacter', 'Cliquez pour saisir', callUser),
              const SizedBox(height: 15),
              _buildTextField('Téléphone à contacter', 'Cliquez pour saisir', contactTextEditingController),
              const SizedBox(height: 15),
              _buildTextField('Intérime', 'Cliquez pour saisir', interim),
              // _buildTextField('Mot de passe', 'Saisissez votre mot de passe', motdepasseTextEditingController, isPassword: true),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _valider,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF406ACC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Envoyer ma demande',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F0F0F),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscureText,
          keyboardType: label == 'Téléphone à contacter' ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            enabled: label == 'Nom et prénom' || label == 'Matricule' ? false : true,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3F3F3F)),
            filled: true,
            fillColor: const Color(0xFFFAF7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: _togglePasswordVisibility,
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.black),
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
          style: const TextStyle(
            color: Color(0xFF0F0F0F),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          items: items.map((value) {
            return DropdownMenuItem<String>(
              value: value['name'],
              child: Text(value['name']),
            );
          }).toList(),
          onChanged: (newValue) {
            controller.text = newValue!;
            final result = items.firstWhere((element) => element['name'] == newValue, orElse: () => -1);
            if(result != -1) {
              if(label == 'Département') setState(() => _departement = result['id']);
              else setState(() => _service = result['id']);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFAF7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.black),
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
          style: const TextStyle(
            color: Color(0xFF0F0F0F),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              });
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3F3F3F)),
            filled: true,
            fillColor: const Color(0xFFFAF7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future _valider() async {
    final nomprenom = nomprenomTextEditingController.text;
    final matricule = matriculeTextEditingController.text;
    final departement = departementTextEditingController.text;
    final service = serviceTextEditingController.text;
    final datedebut = datedebutTextEditingController.text;
    final datefin = datefinTextEditingController.text;
    final lieu = lieuTextEditingController.text;
    final contact = contactTextEditingController.text;
    final password = motdepasseTextEditingController.text;

    if (nomprenom.isEmpty || matricule.isEmpty || departement.isEmpty || service.isEmpty || datedebut.isEmpty || datefin.isEmpty/* || lieu.isEmpty || callUser.text.isEmpty || interim.text.isEmpty || contact.isEmpty*/) {
      _showErrorDialog('Veuillez saisir tous les champs, s\'il vous plaît.');
    } else {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };
      var request = http.Request('POST', Uri.parse('https://rh.madgi.ci/api/v1/leaves'));
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
      if (decode['success']) return Navigator.pushNamed(context, '/valider');
      else _showErrorDialog(decode['message']);
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}






