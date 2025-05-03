import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter_project/ChartPage.dart'; // Lien vers votre page graphique

class HeartRatePage extends StatefulWidget {
  @override
  _HeartRatePageState createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<int> heartRateData = [];
  List<int> spo2Data = [];

  String userName = "";
  String gender = "";
  int age = 0;

  String conditionMessage = ""; // Message pour afficher l'état du rythme cardiaque
  Color backgroundColor = Colors.pink[50]!; // Couleur de fond par défaut

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
    _getUserProfile();
  }

  // Fonction pour récupérer les données du profil utilisateur depuis Firestore
  void _getUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          gender = userDoc['gender'];
          age = int.tryParse(userDoc['age'].toString()) ?? 0;
        });
      }
    }
  }

  // Écouter les changements dans Firebase pour les données du capteur
  void _listenToFirebase() {
    _database.child("sensor_data").onChildAdded.listen((event) {
      final value = event.snapshot.value;
      if (value != null && value is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(value);
        final bpm = data['bpm'];
        final spO2 = data['spo2'];

        setState(() {
          if (bpm != null) heartRateData.add(bpm);
          if (spO2 != null) spo2Data.add(spO2);
          _checkHeartRateCondition(); // Vérifier la condition du rythme cardiaque chaque fois que les données changent
        });
      }
    });
  }

  // Vérifier la condition du rythme cardiaque
  void _checkHeartRateCondition() {
    if (heartRateData.isNotEmpty) {
      int lastHeartRate = heartRateData.last;
      if (lastHeartRate >= 60 && lastHeartRate <= 100) {
        setState(() {
          conditionMessage = 'Rythme cardiaque normal';
          backgroundColor = Colors.pink[50]!; // Fond normal
        });
      } else if (lastHeartRate > 100) {
        setState(() {
          conditionMessage = 'Tachycardie détectée';
          backgroundColor = Colors.red[50]!; // Fond rouge pour tachycardie
        });
        _showAlert("Veuillez consulter votre médecin", Colors.red); // Afficher alerte
      } else if (lastHeartRate <60) {
        setState(() {
          conditionMessage = 'Bradycardie détectée';
          backgroundColor = Colors.blue[50]!; // Fond rouge pour tachycardie
        });
        _showAlert("Veuillez consulter votre médecin", Colors.red); // Afficher alerte
      } 
    }
  }

  // Fonction pour afficher une alerte
  void _showAlert(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 5), // Durée de l'affichage
      ),
    );
  }

  // Fonction pour déconnecter l'utilisateur
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context); // Retourne à la page de connexion (si nécessaire)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Couleur de fond dynamique en fonction du rythme cardiaque
      appBar: AppBar(
        title: Text("Mesure du rythme cardiaque"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section Profil Utilisateur
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName.isNotEmpty ? userName : "Nom non défini",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.pinkAccent),
                      SizedBox(width: 8),
                      Text("Sexe: $gender"),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.pinkAccent),
                      SizedBox(width: 8),
                      Text("Âge: $age ans"),
                    ],
                  ),
                ],
              ),
            ),

            // Section Mesures
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/image2.jpg',
                    width: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 50, color: Colors.red);
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Rythme cardiaque: ${heartRateData.isNotEmpty ? heartRateData.last : 0} BPM",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Saturation Oxygène: ${spo2Data.isNotEmpty ? spo2Data.last : 0} %",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  // Affichage du message de condition
                  Text(
                    conditionMessage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: conditionMessage == 'Rythme cardiaque normal'
                          ? Colors.green
                          : (conditionMessage == 'Tachycardie détectée'
                              ? Colors.red
                              : Colors.transparent), // Aucune couleur pour bradycardie
                    ),
                  ),

                  SizedBox(height: 20),

                  // Bouton "Voir le graphique"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChartPage(
                            heartRateData: heartRateData,
                            spo2Data: spo2Data,
                          ),
                        ),
                      );
                    },
                    child: Text("Voir le graphique"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Bouton de déconnexion
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text("Se déconnecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
