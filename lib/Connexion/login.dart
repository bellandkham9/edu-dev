// ÉCRAN DE CONNEXION
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:edu/Connexion/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_text_field.dart';
import 'ForgotPasswordPage.dart';
import 'User.dart';
import 'homeRouter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Méthode pour se connecter avec Firebase
  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Veuillez remplir tous les champs");
      return;
    }

    try {
      // Connexion avec Firebase Auth
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // 🔹 Récupérer le document utilisateur dans Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        // 🔹 Récupérer le rôle depuis Firestore si présent, sinon "user"
        final roleFromFirestore = userDoc.data()?['role'] ?? 'user';
        final statusFromFirestore = userDoc.data()?['status'] ?? 'status';

        // 🔹 Créer l'objet AppUser
        final appUser = AppUser(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? "",
          email: firebaseUser.email ?? "",
          password: password, // facultatif
          role: roleFromFirestore,
          avatar: firebaseUser.photoURL,
          status: statusFromFirestore,
        );

        // Maintenant appUser.role contient le rôle réel

        // 4️⃣ Naviguer vers l'accueil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeRouter(user: appUser)),
        );

      }
      else {
        _showMessage("Utilisateur introuvable");
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Erreur inconnue");
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
                      "Se connecter",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // EMAIL
                    AuthTextField(
                      label: "Adresse mail",
                      icon: Icons.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    // MOT DE PASSE
                    AuthTextField(
                      label: "Mot de passe",
                      icon: Icons.lock,
                      controller: _passwordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Pas de compte ? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Créer un compte",
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
                        onPressed: login,
                        child: const Text(
                          "Se connecter",
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
}
