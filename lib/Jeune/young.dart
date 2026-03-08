// INTERFACE JEUNE (suite dans le prochain message)
// ============================================
import 'package:edu/Connexion/User.dart';
import 'package:edu/Connexion/homeRouter.dart';
import 'package:flutter/material.dart';
import '../Chat/start_chat.dart';
import '../Profile/ProfilePage.dart';
import '../enfant/startGame.dart';
import '../theme/colors.dart';
import 'CoursesListScreen.dart';



class YoungHomeScreen extends StatefulWidget {
  final AppUser user;

  const YoungHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<YoungHomeScreen> createState() => _YoungHomeScreenState();
}

class _YoungHomeScreenState extends State<YoungHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const CoursesListScreen(),
      const StartChat(),
      const startGame(),
      ProfileScreen(user: widget.user), // ✅ USER RÉEL
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     /* appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),*/
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'jeu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class YoungCoursesPage extends StatelessWidget {
  const YoungCoursesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courses = [
      {'title': 'Introduction à Internet', 'category': 'Informatique', 'level': 'Débutant', 'color': Colors.blue},
      {'title': 'Bases du HTML/CSS', 'category': 'Développement Web', 'level': 'Débutant', 'color': Colors.orange},
      {'title': 'Mathématiques: Algèbre', 'category': 'Mathématiques', 'level': 'Intermédiaire', 'color': Colors.green},
      {'title': 'Anglais Conversation', 'category': 'Langues', 'level': 'Débutant', 'color': Colors.purple},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (course['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.book, color: course['color'] as Color, size: 30),
            ),
            title: Text(course['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${course['category']} • ${course['level']}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
              );
            },
          ),
        );
      },
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['title']),
        backgroundColor: course['color'],
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: (course['color'] as Color).withOpacity(0.2),
              child: Center(
                child: Icon(Icons.play_circle_fill, size: 80, color: course['color']),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Chip(label: Text(course['level'])),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ce cours vous permet d\'apprendre les bases essentielles. Vous découvrirez pas à pas tous les concepts importants avec des exemples pratiques.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chapitres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildChapter('1. Introduction', '10 min'),
                  _buildChapter('2. Concepts de base', '15 min'),
                  _buildChapter('3. Pratique', '20 min'),
                  _buildChapter('4. Quiz final', '5 min'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapter(String title, String duration) {
    return ListTile(
      leading: const Icon(Icons.play_circle_outline),
      title: Text(title),
      trailing: Text(duration),
      onTap: () {},
    );
  }
}

class YoungVideosPage extends StatelessWidget {
  const YoungVideosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Vidéos éducatives'));
  }
}

class YoungForumPage extends StatelessWidget {
  const YoungForumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = [
      {'author': 'Marie', 'message': 'Besoin d\'aide en maths!', 'replies': 5},
      {'author': 'Jean', 'message': 'Quelqu\'un pour réviser ensemble?', 'replies': 3},
      {'author': 'Sophie', 'message': 'Super cours de programmation!', 'replies': 8},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Nouveau post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(post['author'].toString()[0]),
                  ),
                  title: Text(post['author'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(post['message'] as String),
                  trailing: Text('${post['replies']} 💬'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
