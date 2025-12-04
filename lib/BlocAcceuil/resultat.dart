import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
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

  bool isSuccess = false;
  var userInfo;
  var text = 'Enregistrement en cours';
  bool isSuccess1 = false;

  Future getUserInfo() async {
    if(json.decode(widget.scanResult)['Time'] != null) {
      String specificTime = json.decode(widget.scanResult)['Time'];
      List<String> timeParts = specificTime.split(':');
      DateTime now = DateTime.now();
      DateTime specificDateTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]) + 5);
      Duration difference = specificDateTime.difference(now);
      if(difference.isNegative) {
        setState(() {
          text = 'Le code a expiré';
          isSuccess1 = true;
        });
      }
      else {
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
          setState(() => userInfo = decode['data']['user']);
          send();
        }
      }
    }
  }

  send() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.Request('POST', Uri.parse('https://rh.madgi.ci/api/v1/register'));
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    request.body = json.encode({
        'date': json.decode(widget.scanResult)['Date'],
        'time': json.decode(widget.scanResult)['Time'],
        'matricule': userInfo['matricule'],
        'type_device': '$allInfo',
        'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'
      });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    if (decode['code'] == 200) {
      setState(() {
        isSuccess = true;
        text = 'Vous avez emargé avec succès';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              if(isSuccess) ...[
                const SizedBox(height: 20),
                Image.asset(
                  'assets/valider.png',
                  width: 100,
                  height: 100,
                ),
                // const SizedBox(height: 20),
                // Text(
                //   'Résultat du Scan : ${widget.scanResult}',
                //   style: const TextStyle(
                //     fontSize: 18,
                //   ),
                // ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _navigateToHome(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50), // Adjusted padding
                    backgroundColor: const Color(0xFF406ACC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(200, 50), // Minimum size for width and height
                  ),
                  child: const Text(
                    "Aller à l'accueil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              if(isSuccess1) ...[
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _navigateToHome(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50), // Adjusted padding
                    backgroundColor: const Color(0xFF406ACC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(200, 50), // Minimum size for width and height
                  ),
                  child: const Text(
                    "Aller à l'accueil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushNamed(context, '/home');
  }
}