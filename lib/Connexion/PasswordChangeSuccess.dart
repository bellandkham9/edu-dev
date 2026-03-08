import 'package:flutter/material.dart';

import 'login.dart';


class PasswordChangeSuccess extends StatelessWidget {
  const PasswordChangeSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- Backgound image / color ---
          Image.asset(
            "assets/img/bg-2.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // --- Button to open popup ---
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width*0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/img/Emoji.png"),
                  ),
                  Padding(
                    padding:  EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      child:  Text(
                        textAlign:TextAlign.center,
                        "Mot de passe changer avec \nsuccès!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding:  EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      child:  Text(
                        textAlign:TextAlign.center,
                        " If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A8F34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen())
                        );

                      },
                      child: const Text(
                        "Se Connecter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
