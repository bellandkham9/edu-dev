// INTERFACE ENFANT
// ============================================

import 'package:edu/Connexion/User.dart';
import 'package:edu/Profile/ProfilePage.dart';
import 'package:edu/enfant/startGame.dart';
import 'package:flutter/material.dart';

import '../Connexion/homeRouter.dart';
import '../QCM/quizChild.dart';


class ChildHomeScreen extends StatefulWidget {
  final AppUser user;

  const ChildHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const startGame(),
      const EnfantQuizPage(),
      ProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: Text(_currentIndex ==0? "Jeu":_currentIndex==1? "Quizz":"Profile",style: TextStyle(fontWeight: FontWeight.bold),),
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.games, size: 30),
            label: 'Jeux',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz, size: 30),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}


class ChildVideosPage extends StatelessWidget {
  const ChildVideosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final videos = [
      {'title': 'Les Animaux de la Ferme', 'emoji': '🐮', 'duration': '5 min'},
      {'title': 'Apprends les Chiffres', 'emoji': '🔢', 'duration': '8 min'},
      {'title': 'Les Fruits et Légumes', 'emoji': '🍎', 'duration': '6 min'},
      {'title': 'Chanson de l\'Alphabet', 'emoji': '🎤', 'duration': '3 min'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(video['emoji'] as String, style: const TextStyle(fontSize: 30)),
              ),
            ),
            title: Text(video['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text(video['duration'] as String),
            trailing: const Icon(Icons.play_circle_fill, color: Colors.red, size: 40),
          ),
        );
      },
    );
  }
}

class ChildQuizPage extends StatelessWidget {
  const ChildQuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          const Text('Quiz rigolos!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Commencer', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
