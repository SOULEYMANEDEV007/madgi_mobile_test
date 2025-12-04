import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:madgi_mobile/BlocAcceuil/informations.dart';
import 'package:http/http.dart' as http;
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

  Future read(id) async {
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
  }

  Future<void> downloadPdf(String url, String fileName) async {
  try {
    await requestStoragePermission();
    Directory? downloadDir = await getDownloadDirectory();
    if (downloadDir == null) {
      throw Exception('Failed to get download directory');
    }
    String downloadPath = downloadDir.path;
    Dio dio = Dio();
    await dio.download(url, '$downloadPath/$fileName');
    _showErrorDialog('PDF téléchargé !');
  } catch (e) {
    print('Error downloading PDF: $e');
  }
}



  Widget displayFile(String filePath) {
    String extension = p.extension(filePath).toLowerCase();

    if (extension == '.pdf') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 100,
            height: 150,
            child: Icon(
              Icons.file_present_sharp,
              color: Colors.blue,
              size: 60,
            )
          ),
          IconButton(
            onPressed: () => downloadPdf(filePath, 'madgi_info.pdf'), 
            icon: Icon(Icons.download)
          )
        ],
      );
    } else if (['.png', '.jpg', '.jpeg', '.gif', '.bmp'].contains(extension)) {
      return GestureDetector(
        onTap: () {
          showImageViewer(context, Image.network(filePath).image);
        },
        child: Image.network(
          filePath,
          width: 100,
          height: 150,
        ),
      );
    } else {
      return Center(
        child: Text('Unsupported file type'),
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
  if (await Permission.storage.request().isGranted) {
    print('Storage permission granted');
  } else {
    print('Storage permission denied');
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/attention.png', // L'image attention de votre dossier assets
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 10),
            const Text('Information'),
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
    read(widget.data['info']['id']);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => widget.title == 'notification' ? Notifications() : Informations(),
              ),
            );
          },
        ),
        title: const Text("Details"),
        centerTitle: true,
      ),
            body: PopScope(
              canPop: false,
              onPopInvoked: (value) => null,
              child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Note de service",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF0F0F0F),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFECF0FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.data['info']['content'],
                  textAlign: TextAlign.center,
                  ),
            
                ),
                if(widget.data['media'] != null) ...[
                  const SizedBox(height: 17),
                  const Text(
                    "Fichier joint",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xFF0F0F0F),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFECF0FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20,),
                        displayFile("https://rh.madgi.ci/${widget.data['media']['src']}"),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 17),
                const Text(
                  "Emmetteur de la note",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF0F0F0F),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFECF0FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nom & prénom:',
                            style: TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            widget.data['info']['post_name'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF3F3F3F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Téléphone:',
                            style: TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            widget.data['info']['post_phone'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
            
                      const SizedBox(height: 17),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Post:',
                            style: TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            widget.data['departement'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            
            
            
              ],
                      ),
                    ),
                  ),
            ),
      //  bottomNavigationBar: Container(
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