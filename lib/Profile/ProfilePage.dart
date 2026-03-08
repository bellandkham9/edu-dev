import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu/Connexion/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Connexion/login.dart';
import '../database/app_database.dart';
import '../theme/colors.dart';

class Profilepage extends StatelessWidget {
  final AppUser user;

  const Profilepage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(user: user);
  }
}

/* -------------------------------------------------
     WIDGET : CHAMP STATIC + EDITABLE MODERN
--------------------------------------------------*/
class ProfileField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isEditing;
  final bool isPassword;
  final TextEditingController controller;
  final String value;

  const ProfileField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.isEditing,
    required this.value,
    this.isPassword = false,
  });

  @override
  State<ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  bool _obscure = true; // password hidden by default

  @override
  Widget build(BuildContext context) {
    String displayValue =
    widget.isPassword && !widget.isEditing ? '•' * 8 : widget.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(widget.icon, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 5),

                // MODE EDITION
                if (widget.isEditing)
                  TextFormField(
                    controller: widget.controller,
                    obscureText: widget.isPassword ? _obscure : false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(bottom: 4),

                      // Eye icon only if password
                      suffixIcon: widget.isPassword
                          ? IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscure = !_obscure);
                        },
                      )
                          : null,

                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.brown.shade700, width: 1),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  )

                // MODE AFFICHAGE
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayValue,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Container(height: 1, color: Colors.brown),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------
                  ÉCRAN DE PROFIL
--------------------------------------------------*/
class ProfileScreen extends StatefulWidget {
  final AppUser user; // <-- Add this field

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  late String _username;
  late String _email;
  late String _password;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Access user via widget.user
    _username = widget.user.fullName;
    _email = widget.user.email;
    _password = widget.user.password;

    _usernameController.text = _username;
    _emailController.text = _email;
    _passwordController.text = _password;
  }

  void _save() async {
    final updatedUser = AppUser(
      uid: widget.user.uid,
      fullName: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(), // uniquement si tu veux le garder localement
      role: widget.user.role,
      avatar: widget.user.avatar,
      status: widget.user.status,
    );

    setState(() {
      _username = updatedUser.fullName;
      _email = updatedUser.email;
      _password = updatedUser.password;
      _isEditing = false;
    });

    try {
      // 🔹 Mise à jour Firestore (sans stocker le mot de passe)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .update({
        'fullName': updatedUser.fullName,
        'email': updatedUser.email,
        // 'password': updatedUser.password, // mieux ne pas mettre ici
      });

      // 🔹 Mise à jour email FirebaseAuth si différent
      final fbUser = FirebaseAuth.instance.currentUser!;
      if (fbUser.email != updatedUser.email) {
        await fbUser.verifyBeforeUpdateEmail(updatedUser.email);
        await fbUser.sendEmailVerification();
      }

      // 🔹 Mise à jour locale
      await LocalDatabase.instance.Localregister(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informations mises à jour avec succès !")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour: $e")),
      );
    }
  }


  void _cancel() {
    _usernameController.text = _username;
    _emailController.text = _email;
    _passwordController.text = _password;
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height:  MediaQuery.of(context).size.height*0.04,),
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage("assets/img/3d_avatar_2.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height:  MediaQuery.of(context).size.height*0.02,),
            const Text(
              "Profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height:  MediaQuery.of(context).size.height*0.02,),

            // Champs
            ProfileField(
              label: "Nom d'utilisateur",
              icon: Icons.person_outline,
              controller: _usernameController,
              isEditing: _isEditing,
              value: _username,
            ),

            ProfileField(
              label: "Adresse mail",
              icon: Icons.mail_outline,
              controller: _emailController,
              isEditing: _isEditing,
              value: _email,
            ),

            ProfileField(
              label: "Mot de passe",
              icon: Icons.lock_outline,
              controller: _passwordController,
              isEditing: _isEditing,
              isPassword: true,
              value: _password,
            ),

            SizedBox(height:  MediaQuery.of(context).size.height*0.04,),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brun,
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: const Text("Se deconnecter",
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ),

            const SizedBox(height: 10.0),

            // Boutons
            !_isEditing
                ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.user.role=="Adulte"? AppColors.bluebg:widget.user.role=="jeune"?AppColors.green:AppColors.orange,
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                setState(() => _isEditing = true);
              },
              child: const Text("Modifier les informations",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            )
                : Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: widget.user.role=="Adulte"? AppColors.bluebg:widget.user.role=="jeune"?AppColors.green:AppColors.orange,
                      minimumSize: const Size(double.infinity, 50)),
                  onPressed: _save,
                  child: const Text("Enregistrer",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: widget.user.role=="Adulte"? AppColors.bluebg:widget.user.role=="jeune"?AppColors.green:AppColors.orange, width: 2)),
                  onPressed: _cancel,
                  child:  Text("Annuler les modifications",
                      style: TextStyle(
                          fontSize: 18,
                          color: widget.user.role=="Adulte"? AppColors.bluebg:widget.user.role=="jeune"?AppColors.green:AppColors.orange,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
