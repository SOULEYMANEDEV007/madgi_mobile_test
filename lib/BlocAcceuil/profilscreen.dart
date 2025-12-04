// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

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
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController motdepasseTextEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController nom = TextEditingController();
  TextEditingController matricule = TextEditingController();
  TextEditingController tel = TextEditingController();
  TextEditingController email = TextEditingController();
  bool _obscureText = true;
  var image;
  var userInfo;

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
    if (decode['success']) setState(() => userInfo = decode['data']['user']);
    nom.text = userInfo['nom'] ?? '';
    matricule.text = userInfo['matricule'] ?? '';
    tel.text = userInfo['tel'] ?? '';
    email.text = userInfo['email'] ?? '';
  }

  Widget _buildTextField(String label, String hint, controller, {bool isPassword = false}) {
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
          decoration: InputDecoration(
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
          style: const TextStyle(color: Colors.black), // Set text color to black
        ),
      ],
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  submit() async {
    if(_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };
      var request = http.MultipartRequest('POST', Uri.parse('https://rh.madgi.ci/api/v1/update-user'));
      request.fields.addAll({
        'nom': nom.text,
        'tel': tel.text,
        'email': email.text,
        'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);
      if (decode['success']) setState(() => userInfo = decode['data']['user']);
      _showErrorDialog(decode['message']);
    }
  }

  file() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.MultipartRequest('POST', Uri.parse('https://rh.madgi.ci/api/v1/update-user'));
    request.fields.addAll({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
    request.files.add(await http.MultipartFile.fromPath('picture', image.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    if (decode['success']) setState(() => userInfo = decode['data']['user']);
    _showErrorDialog(decode['message']);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/valider.png', // L'image attention de votre dossier assets
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 10),
            const Text('Félicitation'),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Accueil(),
              ),
            );
          },
        ),
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image de profil et autres éléments
            Container(
              padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                            )
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: userInfo != null ? NetworkImage('https://rh.madgi.ci/${userInfo['photo']}') : NetworkImage(''),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Colors.amber
                            ),
                            color: Colors.white
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                              setState(() => image = pickImage);
                              file();
                            }, 
                            icon: const Icon(Icons.edit, color: Colors.amber,)),
                        ))
                    ],
                  ),
                ),
              ),
            ),
            // Champs de saisie
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Nom et prenom', 'Cliquez pour saisir', nom, isPassword: false),
                    const SizedBox(height: 20),
                    _buildTextField('Matricule', 'Cliquez pour saisir', matricule, isPassword: false),
                    const SizedBox(height: 20),
                    _buildTextField('Numéro de téléphone', 'Cliquez pour saisir', tel, isPassword: false),
                    const SizedBox(height: 20),
                    _buildTextField('E-mail', 'Cliquez pour saisir', email, isPassword: false),
                    // const SizedBox(height: 20),
                    // _buildTextField('Mot de passe', 'Saisissez votre mot de passe', isPassword: true), 
                    const SizedBox(height: 20),
                    // Autres champs de saisie
                    GestureDetector(
                      onTap: () => submit(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF406ACC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Envoyer',
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
          ],
        ),
      ),
      // bottomNavigationBar: Container(
      //   width: double.infinity,
      //   height: 95,
      //   decoration: const BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Color(0x3F000000),
      //         blurRadius: 25,
      //         offset: Offset(0, -3),
      //         spreadRadius: 0,
      //       )
      //     ],
      //   ),
      //   child: Padding(
      //     padding: const EdgeInsets.only(left: 28, right: 28, top: 18),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             IconButton(
      //               icon: const Icon(Icons.home, color: Colors.black),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/home');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Accueil',
      //               style: TextStyle(
      //                 color: Colors.black,
      //                 fontSize: 12,
      //                 fontFamily: 'Inter',
      //                 fontWeight: FontWeight.w400,
      //                 height: 1.2,
      //               ),
      //             ),
      //           ],
      //         ),
      //         Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             IconButton(
      //               icon: const Icon(Icons.beach_access, color: Colors.black),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/conger');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Congé',
      //               style: TextStyle(
      //                 color: Colors.black,
      //                 fontSize: 12,
      //                 fontFamily: 'Inter',
      //                 fontWeight: FontWeight.w400,
      //                 height: 1.2,
      //               ),
      //             ),
      //           ],
      //         ),
      //         Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             IconButton(
      //               icon: const Icon(Icons.history, color: Color(0xFF0F0F0F)),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/infos');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Historique',
      //               style: TextStyle(
      //                 color: Color(0xFF0F0F0F),
      //                 fontSize: 12,
      //                 fontFamily: 'Inter',
      //                 fontWeight: FontWeight.w400,
      //                 height: 1.2,
      //               ),
      //             ),
      //           ],
      //         ),
      //         Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             IconButton(
      //               icon: const CircleAvatar(
      //                 radius: 13,
      //                 backgroundImage: AssetImage('assets/person.jpg'),
      //               ),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/profil');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Profil',
      //               style: TextStyle(
      //                 color: Color.fromRGBO(64, 106, 204, 1),
      //                 fontSize: 12,
      //                 fontFamily: 'Inter',
      //                 fontWeight: FontWeight.w400,
      //                 height: 1.2,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
