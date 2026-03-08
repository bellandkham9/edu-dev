import 'package:flutter/material.dart';

import 'PasswordChangeSuccess.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nouveau mot de\npasse",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- TextField ---
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Nouveau mot de passe",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(color: Color(0xFF0A8F34)),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PasswordChangeSuccess()),
                        );
                      },
                      child: const Text(
                        "Changer de mot de passe",
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

// void showForgotPasswordPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.white,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Nouveau mot de\npasse",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // --- TextField ---
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: "Nouveau mot de passe",
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                 ),
//                 obscureText: true,
//               ),
//
//               const SizedBox(height: 10),
//
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {},
//                   child: const Text(
//                     "Mot de passe oublié ?",
//                     style: TextStyle(color: Color(0xFF0A8F34)),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               // --- Button ---
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF0A8F34),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text(
//                     "Changer de mot de passe",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
