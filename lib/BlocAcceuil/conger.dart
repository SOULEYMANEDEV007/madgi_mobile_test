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
  // Couleurs officielles
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF38A169);
  static const Color pendingColor = Color(0xFFDD6B20);
  static const Color rejectedColor = Color(0xFFE53E3E);

  List types = [
    {'id': 1, 'name': 'Demande de congé annuel'},
    {'id': 2, 'name': "Demande d'autorisation d'abscence"},
  ];
  var conges;
  bool _isLoading = true;

  Future getTypes() async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
    };
    var request = http.Request('GET', Uri.parse('http://192.168.1.12:8000/api/v1/type-leaves'));
    request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final data = await response.stream.bytesToString();
    final decode = json.decode(data);
    if (decode['success']) setState(() => types = decode['data']);
  }

  Future getConge() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };
      var request = http.Request('GET', Uri.parse('http://192.168.1.12:8000/api/v1/leaves'));
      request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);
      if (decode['success']) {
        setState(() => conges = decode['data']);
      }
    } catch (e) {
      print('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getTypes();
    getConge();
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
                  'Gestion des congés',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  _showBottomSheet(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Consultez et gérez vos demandes de congé',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color badgeTextColor; // Renommé pour éviter la collision
    String label;

    switch (status.toLowerCase()) {
      case 'approuvé':
      case 'validé':
        backgroundColor = successColor.withOpacity(0.1);
        badgeTextColor = successColor; // Utiliser le nouveau nom
        label = 'Validé';
        break;
      case 'en attente':
      case 'pending':
        backgroundColor = pendingColor.withOpacity(0.1);
        badgeTextColor = pendingColor; // Utiliser le nouveau nom
        label = 'En attente';
        break;
      case 'rejeté':
      case 'refusé':
        backgroundColor = rejectedColor.withOpacity(0.1);
        badgeTextColor = rejectedColor; // Utiliser le nouveau nom
        label = 'Rejeté';
        break;
      default:
        backgroundColor = mediumGray;
        badgeTextColor = textColor; // Maintenant ça référence la constante de classe
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeTextColor, // Utiliser le nouveau nom
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCongeCard(Map<String, dynamic> conge) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Detail(data: conge),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: mediumGray, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    conge['type']?.toLowerCase().contains('annuel') ?? false
                        ? Icons.beach_access
                        : Icons.person_off_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conge['type'] ?? 'Type non spécifié',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildStatusBadge(conge['status'] ?? 'En attente'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: mediumGray,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${conge['conge']['start_date']} - ${conge['conge']['end_date']}",
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (conge['conge']['place_enjoyment']?.isNotEmpty ?? false)
                        Row(
                          children: [
                            Icon(
                              Icons.place,
                              color: mediumGray,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                conge['conge']['place_enjoyment'] ?? '',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: mediumGray,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.beach_access,
              color: primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune demande de congé',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Vous n\'avez pas encore soumis de demande de congé. Créez-en une nouvelle pour commencer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _showBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Nouvelle demande',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: mediumGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Type de demande',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor.withOpacity(0.6)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez le type de congé que vous souhaitez demander',
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: types.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final type = types[index];
                        return Material(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Formulaire(typeId: type['id']),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: mediumGray, width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      type['name'].contains('annuel')
                                          ? Icons.beach_access
                                          : Icons.person_off_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      type['name'],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: mediumGray,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: mediumGray),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: backgroundColor,
                onRefresh: () async {
                  await getConge();
                },
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                )
                    : (conges == null || conges.isEmpty)
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: conges.length,
                  itemBuilder: (context, index) {
                    return _buildCongeCard(conges[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: conges != null && conges.isNotEmpty
          ? FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}