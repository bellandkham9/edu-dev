import 'package:flutter/material.dart';
import 'User.dart';
import 'homeRouter.dart';

class CreationCompteSucces extends StatefulWidget {
  final AppUser user;

  const CreationCompteSucces({
    super.key,
    required this.user,
  });

  @override
  State<CreationCompteSucces> createState() => _CreationCompteSuccesState();
}

class _CreationCompteSuccesState extends State<CreationCompteSucces> {
  @override
  void initState() {
    super.initState();

    // ⏳ Attendre 3 secondes puis rediriger
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeRouter(user: widget.user),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// --- Background image ---
          Image.asset(
            "assets/img/bg-2.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          /// --- Popup content ---
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Image(
                    image: AssetImage("assets/img/Emoji.png"),
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Compte créé avec succès 🎉",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bienvenue dans l’application.\nRedirection en cours...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
