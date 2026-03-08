import 'package:edu/Adulte/Adult.dart';
import 'package:edu/Connexion/User.dart';
import 'package:edu/Connexion/welcome.dart';
import 'package:edu/Jeune/young.dart';
import 'package:edu/admin/screens/admin_courses_screen.dart';
import 'package:edu/enfant/child.dart';
import 'package:flutter/material.dart';

class HomeRouter extends StatelessWidget {
  final AppUser  user;

  const HomeRouter({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case 'enfant':
        return ChildHomeScreen(user: user);
      case 'jeune':
        return YoungHomeScreen(user: user);
      case 'Adulte':
        return AdultHomeScreen(user: user);
      case 'admin':
        return AdminCoursesScreen();
      default:
        return const WelcomeScreen();
    }
  }
}


