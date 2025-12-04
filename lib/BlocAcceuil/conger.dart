// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/detail.dart';
import 'package:madgi_mobile/BlocAcceuil/formulaire.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'acceuil.dart';

class Conger extends StatefulWidget {
  final back;
  const Conger({super.key, this.back = false});

  @override
  State<Conger> createState() => _CongerState();
}

class _CongerState extends State<Conger> {

  List types = [
    {'id': 1, 'name': 'Demande de congé annuel'},
    {'id': 2, 'name': "Demande d'autorisation d'abscence"},
  ];
  var conges;

  Future getTypes() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/type-leaves'));
    request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    print(decode);
    if (decode['success']) setState(() => types = decode['data']);
  }

  Future getConge() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/leaves'));
    request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    if (decode['success']) setState(() => conges = decode['data']);
  }
  
  @override
  void initState() {
    super.initState();
    // getTypes();
    getConge();
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
          'Liste des demandes',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30, color: Colors.blue),
            onPressed: () {
              _showBottomSheet(context);
            },
          ),
          const SizedBox(width: 10,)
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (value) => null,
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.25,
            child: ListView.builder(
              itemCount: conges != null ? conges.length : 0,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail(data: conges[i]),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conges[i]['type'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${conges[i]['conge']['start_date']} - ${conges[i]['conge']['end_date']}",
                            style: const TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
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
      //               icon: const Icon(Icons.beach_access, color: Color(0xFF406ACC)),
      //               onPressed: () {
      //                 Navigator.pushNamed(context, '/conger');
      //               },
      //             ),
      //             const SizedBox(height: 9),
      //             const Text(
      //               'Congé',
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Center(
                child: Text(
                  'Selectionner le type pour continuer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(types.length, (index) => GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Formulaire(typeId: types[index]['id']),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    types[index]['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),),
              )
            ],
          ),
        );
      },
    );
  }
}
