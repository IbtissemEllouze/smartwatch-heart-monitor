import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart'; // Assure-toi que cette page existe
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();


  bool _isLoading = false;
  bool _obscurePassword = true; // Pour masquer/afficher le mot de passe
  String _gender = 'Femme'; // Valeur par défaut

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim(); // On n'utilise plus confirmPassword
    String name = _nameController.text.trim();
    String age = _ageController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || _gender.isEmpty || age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      // Ajouter les données dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'gender': _gender,  // Utilisation de _gender
        'age': age,
        'uid': userCredential.user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inscription réussie ! Connectez-vous."), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erreur d'inscription";

      if (e.code == 'weak-password') {
        errorMessage = "Le mot de passe est trop faible";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Cet email est déjà utilisé";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Email invalide";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/image1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
                    Text(
                      "INSCRIPTION",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Champ pour le nom complet
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.black),
                            border: InputBorder.none,
                            hintText: "Nom complet",
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Champ pour l'email
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.black),
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Champ pour le mot de passe
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.black),
                            border: InputBorder.none,
                            hintText: "Mot de passe",
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Champ pour l'âge
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _ageController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                            border: InputBorder.none,
                            hintText: "Âge",
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Sexe: "),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Femme',
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                              Text("Femme"),
                              Radio<String>(
                                value: 'Homme',
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                              Text("Homme"),
                            ],
                          ),
                        ],
                      ),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _register,
                              child: Text("S'inscrire"),
                            ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        ),
                        child: Text("Déjà un compte ? Connectez-vous"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
