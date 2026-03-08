import 'package:edu/Connexion/welcome.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';



Future<void> main() async {
  // ✅ Assure que Flutter est initialisé avant Firebase
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBbtIP2N-qTedwwKhfJ-CWVIYZMFycH0FE',
        appId: '1:129589632246:android:3088d413727787831320d7',
        messagingSenderId: '129589632246',
        projectId: 'edudev-af315',
      ),
    );
  }
  else if (Platform.isIOS) {
  await Firebase.initializeApp();
  }

  runApp(MyApp(), // Wrap your app
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'edudev',
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
