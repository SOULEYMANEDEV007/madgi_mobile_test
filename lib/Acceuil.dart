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

  final TextEditingController matricule = TextEditingController();
  late String _currentDate;
  late String _currentTime;
  String _qrCodeData = "";
  late Timer _timer;
  bool hasPreference = false;
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
    if (decode['success']) setState(() {
      userInfo = decode['data']['user'];
      matricule.text = userInfo['matricule'];
    });
    _updateQRCodeData();
  }

  checkPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasPreference = prefs.containsKey('save');
      print(prefs.getString('save'));
      if(hasPreference) matricule.text = prefs.getString('save')!;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    // checkPreference();
    _updateDateTime();
    _startTimers();
  }

  void _startTimers() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateQRCodeData();
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final timeFormatter = DateFormat('HH:mm:ss');
    setState(() {
      _currentDate = dateFormatter.format(now);
      _currentTime = timeFormatter.format(now);
    });
  }

  void _updateQRCodeData() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.androidInfo;
    final allInfo = "${deviceInfo.id}.${deviceInfo.device}.${deviceInfo.serialNumber}.${deviceInfo.product}";
    setState(() {
      _qrCodeData = json.encode({
        "Date": "$_currentDate", 
        "Time": "$_currentTime",
        "matricule": matricule.text,
        "type_device": '$allInfo',
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: <Widget>[
            ClipPath(
              clipper: MyClipper(),
              child: Container(
                width: double.infinity,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 251, 141, 6),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        _currentDate ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Text(
                        _currentTime ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // if(!hasPreference) ...[
                    //   Padding(
                    //     padding: const EdgeInsets.all(15.0),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           'Matricule',
                    //           style: const TextStyle(
                    //             color: Color(0xFF0F0F0F),
                    //             fontSize: 16,
                    //           ),
                    //         ),
                    //         const SizedBox(height: 10),
                    //         TextField(
                    //           controller: matricule,
                    //           decoration: InputDecoration(
                    //             hintStyle: const TextStyle(color: Color(0xFF3F3F3F)),
                    //             filled: true,
                    //             border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(8),
                    //               borderSide: BorderSide.none,
                    //             ),
                    //           ),
                    //           onChanged: (value) => _updateQRCodeData(),
                    //           style: const TextStyle(color: Colors.black), // Set text color to black
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   if(matricule.text.isNotEmpty) ...[
                    //     Align(
                    //       alignment: Alignment.centerRight,
                    //       child: TextButton(
                    //         onPressed: () {
                    //           showDialog(
                    //             context: context,
                    //             builder: (ctx) => AlertDialog(
                    //               title: Row(
                    //                 children: [
                    //                   Image.asset(
                    //                     'assets/attention.png', // L'image attention de votre dossier assets
                    //                     width: 24,
                    //                     height: 24,
                    //                   ),
                    //                   const SizedBox(width: 10),
                    //                   const Text('Information'),
                    //                 ],
                    //               ),
                    //               content: Text("Sauvegarder ce matricule pour les prochaines connexion"),
                    //               actions: <Widget>[
                    //                 TextButton(
                    //                   child: const Text('Annuler'),
                    //                   onPressed: () {
                    //                     Navigator.of(ctx).pop();
                    //                   },
                    //                 ),
                    //                 TextButton(
                    //                   child: const Text('Enregistrer'),
                    //                   onPressed: () async {
                    //                     final prefs = await SharedPreferences.getInstance();
                    //                     await prefs.setString('save', matricule.text);
                    //                     Navigator.of(ctx).pop();
                    //                     showDialog(
                    //                       context: context,
                    //                       builder: (ctx) => AlertDialog(
                    //                         title: Row(
                    //                           children: [
                    //                             Image.asset(
                    //                               'assets/attention.png', // L'image attention de votre dossier assets
                    //                               width: 24,
                    //                               height: 24,
                    //                             ),
                    //                             const SizedBox(width: 10),
                    //                             const Text('Information'),
                    //                           ],
                    //                         ),
                    //                         content: Text("Matricule sauvegarder"),
                    //                         actions: <Widget>[
                    //                           TextButton(
                    //                             child: const Text('Retour'),
                    //                             onPressed: () {
                    //                               checkPreference();
                    //                               Navigator.of(ctx).pop();
                    //                             },
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     );
                    //                   },
                    //                 )
                    //               ],
                    //             ),
                    //           );
                    //         }, 
                    //         child: Text(
                    //           'Sauvegarder ce matricule ?',
                    //         )
                    //       ),
                    //     ),
                    //     const SizedBox(height: 15),
                    //   ]
                    // ],
                    if(matricule.text.isNotEmpty/* || hasPreference*/) ...[
                      const Text(
                        "SCANNEZ MOI!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      QrImageView(
                        data: _qrCodeData,
                        version: QrVersions.auto,
                        gapless: false,
                        size: 320,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}