import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:madgi_mobile/BlocAcceuil/acceuil.dart';
import 'package:madgi_mobile/BlocAcceuil/apercu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
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
      var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/user-info'));
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
      var request = http.Request('GET', Uri.parse('https://rh.madgi.ci/api/v1/infos'));
      request.body = json.encode({'user_id': '${json.decode(prefs.getString('userInfo')!)['user']['id']}'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final data = await response.stream.bytesToString();
      final decode = json.decode(data);
      if (decode['success']) setState(() => infos = decode['data']);
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
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
                  'Notifications',
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
            'Consultez vos dernières notifications',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool _isNotificationRead(Map<String, dynamic> notification) {
    return notification['info']['userinfos'] != null &&
        notification['info']['userinfos']['user_id'] == userInfo?['id'] &&
        notification['info']['userinfos']['info_id'] == notification['info']['id'];
  }

  Widget _buildNotificationBadge(bool isRead) {
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

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = _isNotificationRead(notification);
    final hasMedia = notification['media'] != null;

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
                builder: (context) => Apercu(title: 'notification', data: notification),
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
                // Indicateur visuel
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: _buildNotificationBadge(isRead),
                ),
                const SizedBox(width: 12),

                // Icône de notification
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(isRead ? 0.1 : 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasMedia ? Icons.attach_file : Icons.notifications,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Contenu de la notification
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Note d'information",
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
                                    'Fichier',
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
                        notification['info']['content'] ?? '',
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
                            'Aujourd\'hui',
                            style: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
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
              Icons.notifications_none,
              color: primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune notification',
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
              'Vous n\'avez pas encore de notifications.\nElles apparaîtront ici lorsqu\'elles seront disponibles.',
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
            'Chargement des notifications...',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
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
                    return _buildNotificationCard(infos[index], index);
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