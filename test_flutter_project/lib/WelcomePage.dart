import 'package:flutter/material.dart';
import 'LoginPage.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // L'image en arrière-plan
  Image.asset(
    'images/heartbeat.jpg',
            fit: BoxFit.cover, // L' kimage prend toute la taille de l'écran
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, size: 50, color: Colors.red);
            },
          ),
          // Contenu par-dessus l'image
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50), // Un espace pour éviter que le bouton soit collé en bas
            ],
          ),
          // Le bouton placé en bas de l'écran avec une taille plus grande
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30), // Un peu d'espace autour du bouton
              child: Container(
                width: MediaQuery.of(context).size.width / 2, // Le bouton occupe la moitié de la largeur de l'écran
                height: 60, // Hauteur du bouton
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.7), // Bouton rose avec transparence
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Transparent pour utiliser la couleur du conteneur
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Texte gras
                      color: Colors.black, // Texte en noir
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}