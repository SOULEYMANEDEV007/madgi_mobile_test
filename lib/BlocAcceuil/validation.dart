import 'package:flutter/material.dart';

class Validation extends StatelessWidget {
  const Validation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/valider.png",
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "Félicitation votre demande à été bien envoyée",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
        ),
      ),
    );
  }
  void _navigateToHome(BuildContext context) {
    Navigator.pushNamed(context, '/home');
  }
}
