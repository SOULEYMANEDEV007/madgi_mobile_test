import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/conger.dart';

class Detail extends StatefulWidget {
  final data;
  const Detail({super.key, required this.data});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
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
                builder: (context) => Conger(),
              ),
            );
          },
        ),
        title: const Text("Details"),
        centerTitle: true,
      ),
            body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Information Personnelle",
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
                child:  Column(
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
                          widget.data['conge']['fullname'] ?? '',
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
                          'Matricule:',
                          style: TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.data['conge']['matricule'] ?? '',
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
                          'Département:',
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
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Service:',
                          style: TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.data['service'] ?? '',
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
              const SizedBox(height: 17),
              const Text(
                "Personne à contacter",
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
                          widget.data['conge']['call_user_name'] ?? '',
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
                          widget.data['conge']['call_phone'] ?? '',
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
              const SizedBox(height: 17),
              const Text(
                "Detail de la demande",
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
                          'Date demande:',
                          style: TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.data['conge']['start_date'] ?? '',
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
                          'Date reprise:',
                          style: TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.data['conge']['end_date'] ?? '',
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
                          'Lieux de jouissance:',
                          style: TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.data['conge']['place_enjoyment'] ?? '',
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
                          'Interime:',
                          style: TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.data['conge']['interim'] ?? '',
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
                          'Statut de la demande:',
                          style: TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: widget.data['conge']['status'] == 'SUCCESS' ? Colors.green 
                            : widget.data['conge']['status'] == 'ERROR' ? Colors.red 
                            : Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.data['conge']['status'] == 'SUCCESS' ? 'ACCEPTE'
                            : widget.data['conge']['status'] == 'ERROR' ? 'REFUSE' 
                            : 'En cours',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              if(widget.data['medias'].length != 0) ...[
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
                      GestureDetector(
                        onTap: () {
                          showImageViewer(context, Image.network("https://rh.madgi.ci/${widget.data['medias'].first['src']}").image);
                        },
                        child: Image.network("https://rh.madgi.ci/${widget.data['medias'].first['src']}",width: 100, height: 150,),
                      ),
                    ],
                  ),
                ),
              ]
            ],
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
      //                 Navigator.pushNamed(context, '/apercu');
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
}