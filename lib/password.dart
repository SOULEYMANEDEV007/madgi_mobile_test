import 'package:flutter/material.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  bool _isObscure = true;
  final TextEditingController motdepasseTextEditingController = TextEditingController();
  final TextEditingController confirmMotdepasseTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController nomTextEditingController = TextEditingController();
  final TextEditingController prenomTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.blue,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10), // Espace supplémentaire au-dessus de l'image
                // Image d'asset
                Image.asset(
                  'assets/images.jpg',
                  width: 80, // Largeur de l'image
                  height: 80, // Hauteur de l'image
                ),
                const SizedBox(height: 10),
                // Texte "Password"
                const Text(
                  'Mot de passe',
                  style: TextStyle(
                    fontSize: 25, // Taille de la police
                    fontWeight: FontWeight.bold, // Poids de la police en gras
                    color: Colors.blue, // Couleur du texte en bleu
                  ),
                ),
                const SizedBox(height: 10), // Espacement entre le texte "Inscription" et les champs de saisie
                // Champ de nom
                TextField(
                  controller: nomTextEditingController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Bordure arrondie
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Espacement entre les champs de nom et de prénom
                // Champ de prénom
               
                TextField(
                  controller: emailTextEditingController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Bordure arrondie
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Espacement entre les champs d'e-mail et de mot de passe
                // Champ de mot de passe
                TextField(
                  obscureText: _isObscure,
                  controller: motdepasseTextEditingController,
                  decoration: InputDecoration(
                    labelText: 'Nouveau Mot de passe',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Bordure arrondie
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off), // Icône pour masquer ou afficher le mot de passe
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Espacement entre les champs de mot de passe et de confirmation du mot de passe
                // Champ de confirmation de mot de passe
                TextField(
                  obscureText: _isObscure,
                  controller: confirmMotdepasseTextEditingController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Bordure arrondie
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off), // Icône pour masquer ou afficher le mot de passe
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Espacement entre les champs de saisie et le bouton d'inscription
                // Bouton "S'inscrire"
                ElevatedButton(
                  onPressed: () {
                    // Action lorsque le bouton "S'inscrire" est pressé
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Couleur de fond orange
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Bordure arrondie
                    ),
                    //minimumSize: Size(double.infinity, 50), // Taille minimale pour le bouton
                  ),
                  child: const Text(
                    "CONNEXION",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20), // Espacement entre le bouton et le texte "Mot de passe oublié"
                // Texte "Mot de passe oublié"
                GestureDetector(
                  onTap: () {
                    // Action lorsque le texte "Mot de passe oublié" est pressé
                  },
                  child: const Text(
                    'Mot de passe oublié',
                    style: TextStyle(
                      color: Colors.blue, // Couleur du texte en bleu
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
