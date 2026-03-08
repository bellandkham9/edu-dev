import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu/Connexion/User.dart';
import 'package:edu/Connexion/homeRouter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../theme/colors.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_text_field.dart';
import 'CreationCompteSucces.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'jeune';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("Tous les champs sont obligatoires");
      return;
    }

    try {
      // 1️⃣ Créer l'utilisateur dans Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        _showMessage("Erreur lors de la création du compte");
        return;
      }

      // 2️⃣ Créer AppUser pour notre collection Firestore
      final user = AppUser(
        uid: firebaseUser.uid,
        fullName: name,
        email: email,
        password: password, // tu peux aussi ne pas stocker le password ici
        role: _selectedRole,
        avatar: '',
        status: ''
      );

      // 3️⃣ Ajouter l'utilisateur à Firestore
      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      // 🔹 Mettre à jour la variable locale
      LocalDatabase.instance.Localregister(user);

      // 4️⃣ Naviguer vers l'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CreationCompteSucces(user: user,)),
      );

    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Erreur inconnue");
    } catch (e) {
      _showMessage("Erreur: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/img/bg-1.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              child: AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: "Nom d'utilisateur",
                      icon: Icons.person,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 25),
                    AuthTextField(
                      label: "Adresse mail",
                      icon: Icons.email,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 25),
                    AuthTextField(
                      label: "Mot de passe",
                      icon: Icons.lock,
                      obscure: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Je suis :',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10),
                        _buildRoleCard('enfant', '👶 Enfant', 'Jeux et vidéos', Colors.orange),
                        const SizedBox(width: 10),
                        _buildRoleCard('jeune', '🧑 Jeune', 'Cours et forum', AppColors.green),
                        const SizedBox(width: 10),
                        _buildRoleCard('Adulte', '👨‍💼 Adulte', 'Formations pro', AppColors.bluebg),
                        const SizedBox(width: 10),
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Vous avez déjà un compte? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: register,
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, String title, String subtitle, Color color) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? color : Colors.grey),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              /*  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),*/
              ],
            ),
          ],
        ),
      ),
    );
  }
}
