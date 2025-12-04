import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:madgi_mobile/BlocAcceuil/apercu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Informations extends StatefulWidget {
  const Informations({super.key});

  @override
  State<Informations> createState() => _InformationsState();
}

class _InformationsState extends State<Informations> {

  var infos;
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
    getInfo();
  }

  Future getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/infos'));
    request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    if (decode['success']) setState(() => infos = decode['data']);
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Accueil(),
              ),
            );
          },
        ),
        title: const Text(
          'Informations',
          style: TextStyle(color: Colors.black),
        ),
        
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (value) => null,
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemCount: infos != null ? infos.length : 0,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Apercu(data: infos[i]),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: infos[i]['info']['userinfos'] != null && infos[i]['info']['userinfos']['user_id'] == userInfo['id'] && infos[i]['info']['userinfos']['info_id'] == infos[i]['info']['id'] ? const Color(0xFFE8E8E8) : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Note d'informations aux personnels",
                            style: TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: Text(
                              infos[i]['info']['content']?? '',
                              maxLines: 2,
                              style: const TextStyle(
                                color: Color(0xFF0F0F0F),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_outlined),
                    ],
                  ),
                ),
              ),
            ),
          )
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
      //               icon: const Icon(Icons.home, color: Color(0xFF0F0F0F)),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/home');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Accueil',
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
      //               icon: const Icon(Icons.beach_access, color: Color(0xFF0F0F0F)),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/conger');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Congé',
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
      //               icon: const Icon(Icons.history, color: Color(0xFF406ACC)),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/infos');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Historique',
      //               style: TextStyle(
      //                 color: Color(0xFF406ACC),
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
      //                 color: Color(0xFF0F0F0F),
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