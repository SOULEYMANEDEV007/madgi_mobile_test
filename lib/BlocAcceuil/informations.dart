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
  // Couleurs officielles ivoiriennes
  static const Color primaryColor = Color(0xFFF77F00);
  static const Color secondaryColor = Color(0xFF009A44);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color unreadColor = Color(0xFFF0F7FF);

  var infos;
  var userInfo;
  bool _isLoading = true;

  Future<void> getUserInfo() async {
    try {
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
      if (decode['success']) setState(() => userInfo = decode['data']['user']);
      await getInfo();
    } catch (e) {
      print('❌ Erreur chargement infos utilisateur: $e');
    }
  }

  Future<void> getInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${json.decode(prefs.getString('userInfo')!)['token']}'
      };
      var request = http.Request('GET', Uri.parse('http://192.168.1.12:8000/api/v1/infos'));
      request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);
      if (decode['success']) setState(() => infos = decode['data']);
    } catch (e) {
      print('❌ Erreur chargement informations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
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
                  'Informations',
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
            'Consultez les informations officielles',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool _isInformationRead(Map<String, dynamic> information) {
    return information['info']['userinfos'] != null &&
        information['info']['userinfos']['user_id'] == userInfo?['id'] &&
        information['info']['userinfos']['info_id'] == information['info']['id'];
  }

  Widget _buildStatusBadge(bool isRead) {
    if (isRead) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: mediumGray,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
      );
    }
  }

  Widget _buildInformationCard(Map<String, dynamic> information, int index) {
    final isRead = _isInformationRead(information);
    final hasMedia = information['media'] != null;
    final content = information['info']['content'] ?? '';
    final truncatedContent = content.length > 100 ? '${content.substring(0, 100)}...' : content;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Material(
        color: isRead ? backgroundColor : unreadColor,
        borderRadius: BorderRadius.circular(16),
        elevation: isRead ? 0 : 1,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Apercu(data: information),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isRead ? mediumGray : primaryColor.withOpacity(0.3),
                width: isRead ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicateur de statut
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: _buildStatusBadge(isRead),
                ),
                const SizedBox(width: 12),

                // Icône du type d'information
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isRead ? mediumGray.withOpacity(0.2) : primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasMedia ? Icons.attach_file : Icons.info_outline,
                    color: isRead ? mediumGray : primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Contenu de l'information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              information['info']['title'] ?? "Note d'information",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasMedia)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_file,
                                    size: 12,
                                    color: secondaryColor,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Pièce jointe',
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        truncatedContent,
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(information['info']['created_at']),
                            style: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRead ? mediumGray.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isRead ? 'Lue' : 'Nouvelle',
                              style: TextStyle(
                                color: isRead ? mediumGray : primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: mediumGray,
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
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Aujourd'hui";
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Date inconnue';
    }
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
              Icons.info_outline,
              color: primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune information',
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
              'Aucune information n\'est disponible pour le moment.\nElles apparaîtront ici lorsqu\'elles seront publiées.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Chargement des informations...',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    if (infos == null || infos.isEmpty) return const SizedBox();

    final totalInfos = infos.length;
    final readInfos = infos.where((info) => _isInformationRead(info)).length;
    final unreadInfos = totalInfos - readInfos;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mediumGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.list,
            'Total',
            '$totalInfos',
            primaryColor,
          ),
          Container(
            width: 1,
            height: 40,
            color: mediumGray,
          ),
          _buildStatItem(
            Icons.mark_email_unread,
            'Non lues',
            '$unreadInfos',
            primaryColor,
          ),
          Container(
            width: 1,
            height: 40,
            color: mediumGray,
          ),
          _buildStatItem(
            Icons.mark_email_read,
            'Lues',
            '$readInfos',
            secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
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

            // Section statistiques
            if (!_isLoading && infos != null && infos.isNotEmpty)
              _buildStatsSection(),

            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: backgroundColor,
                onRefresh: () async {
                  await getInfo();
                },
                child: _isLoading
                    ? _buildLoadingState()
                    : (infos == null || infos.isEmpty)
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: infos.length,
                  itemBuilder: (context, index) {
                    return _buildInformationCard(infos[index], index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}