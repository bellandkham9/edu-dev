import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

import 'package:lottie/lottie.dart';

import '../theme/colors.dart';


// Écran de menu principal
class startGame extends StatelessWidget {
  const startGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity*0.98,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.4,
                  height: MediaQuery.of(context).size.height*0.3,
                  child: Lottie.asset("assets/lottie/globe.json")),
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              const Text(
                'Sauve la planète!',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
               SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              _buildMenuButton(
                context,
                'Jouer',
                Icons.play_arrow,
                Colors.orange,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              _buildMenuButton(
                context,
                'Apprendre',
                Icons.school,
                Colors.purple,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EducationScreen()),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              _buildMenuButton(
                context,
                'Badges',
                Icons.emoji_events,
                Colors.amber,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BadgesScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 30),
      label: Text(text, style: const TextStyle(fontSize: 24)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
      ),
    );
  }
}
// Écran éducatif
class EducationScreen extends StatelessWidget {
  const EducationScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> facts = const [
    {
      'title': 'Le plastique',
      'icon': '🍾',
      'fact': 'Une bouteille en plastique met 450 ans à se décomposer dans la nature!',
      'color': Colors.blue,
    },
    {
      'title': 'Le recyclage',
      'icon': '♻️',
      'fact': 'Recycler une tonne de papier sauve 17 arbres!',
      'color': Colors.green,
    },
    {
      'title': 'Le compost',
      'icon': '🍎',
      'fact': 'Les déchets organiques peuvent devenir un engrais naturel pour les plantes.',
      'color': Colors.brown,
    },
    {
      'title': 'Les canettes',
      'icon': '🥫',
      'fact': 'Une canette en aluminium peut être recyclée à l\'infini!',
      'color': Colors.grey,
    },
    {
      'title': 'L\'océan',
      'icon': '🌊',
      'fact': 'Chaque année, 8 millions de tonnes de plastique finissent dans les océans.',
      'color': Colors.lightBlue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Protéger la planète',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity*0.98,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: facts.length,
          itemBuilder: (context, index) {
            final fact = facts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      (fact['color'] as Color).withOpacity(0.2),
                      Colors.white,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      fact['icon'],
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fact['title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: fact['color'],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fact['fact'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Écran des badges
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Non connecté")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Badges',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body:  StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('badges')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final badges = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index].data() as Map<String, dynamic>;
              return _buildBadge(
                badge['emoji'],
                badge['title'],
                badge['unlocked'] ? 'Débloqué' : 'Verrouillé',
                Colors.green,
                badge['unlocked'] ?? false,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBadge(String emoji, String title, String requirement, Color color, bool unlocked) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: unlocked ? color.withOpacity(0.2) : Colors.grey.shade300,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 60,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: unlocked ? color : Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              requirement,
              style: TextStyle(
                fontSize: 12,
                color: unlocked ? Colors.grey.shade700 : Colors.grey,
              ),
            ),
            if (!unlocked)
              const Icon(Icons.lock, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class Waste {
  final String name;
  final String emoji;
  final String category;
  Offset position;
  double velocity;
  bool isDragging;

  Waste({
    required this.name,
    required this.emoji,
    required this.category,
    required this.position,
    this.velocity = 2.0,
    this.isDragging = false,
  });
}

class Bin {
  final String category;
  final Color color;
  final String label;
  final IconData icon;

  Bin({
    required this.category,
    required this.color,
    required this.label,
    required this.icon,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int score = 0;
  int lives = 3;
  int level = 1;
  List<Waste> wastes = [];
  Timer? gameTimer;
  Timer? animationTimer;
  bool isPaused = false;

  final List<Bin> bins = [
    Bin(category: 'recyclable', color: Colors.yellow.shade700, label: 'Recyclable', icon: Icons.recycling),
    Bin(category: 'organic', color: Colors.green.shade700, label: 'Organique', icon: Icons.grass),
    Bin(category: 'general', color: Colors.grey.shade700, label: 'Général', icon: Icons.delete),
    Bin(category: 'electronic', color: Colors.blue.shade700, label: 'Électronique', icon: Icons.devices),
  ];

  final List<Map<String, String>> wasteItems = [
    // Recyclables (12 items)
    {'name': 'Bouteille', 'emoji': '🍾', 'category': 'recyclable'},
    {'name': 'Canette', 'emoji': '🥫', 'category': 'recyclable'},
    {'name': 'Journal', 'emoji': '📰', 'category': 'recyclable'},
    {'name': 'Carton', 'emoji': '📦', 'category': 'recyclable'},
    {'name': 'Bouteille plastique', 'emoji': '🧴', 'category': 'recyclable'},
    {'name': 'Papier', 'emoji': '📄', 'category': 'recyclable'},
    {'name': 'Magazine', 'emoji': '📔', 'category': 'recyclable'},
    {'name': 'Boîte', 'emoji': '📦', 'category': 'recyclable'},
    {'name': 'Canette alu', 'emoji': '🥤', 'category': 'recyclable'},
    {'name': 'Bouteille verre', 'emoji': '🍷', 'category': 'recyclable'},
    {'name': 'Enveloppe', 'emoji': '✉️', 'category': 'recyclable'},
    {'name': 'Catalogue', 'emoji': '📰', 'category': 'recyclable'},

    // Organiques (12 items)
    {'name': 'Pomme', 'emoji': '🍎', 'category': 'organic'},
    {'name': 'Banane', 'emoji': '🍌', 'category': 'organic'},
    {'name': 'Feuille', 'emoji': '🍂', 'category': 'organic'},
    {'name': 'Carotte', 'emoji': '🥕', 'category': 'organic'},
    {'name': 'Orange', 'emoji': '🍊', 'category': 'organic'},
    {'name': 'Tomate', 'emoji': '🍅', 'category': 'organic'},
    {'name': 'Laitue', 'emoji': '🥬', 'category': 'organic'},
    {'name': 'Branche', 'emoji': '🌿', 'category': 'organic'},
    {'name': 'Épluchure', 'emoji': '🥔', 'category': 'organic'},
    {'name': 'Pain', 'emoji': '🍞', 'category': 'organic'},
    {'name': 'Fleur fanée', 'emoji': '🥀', 'category': 'organic'},
    {'name': 'Coquille œuf', 'emoji': '🥚', 'category': 'organic'},

    // Généraux (12 items)
    {'name': 'Sac', 'emoji': '👜', 'category': 'general'},
    {'name': 'Stylo', 'emoji': '🖊️', 'category': 'general'},
    {'name': 'Couche', 'emoji': '🧷', 'category': 'general'},
    {'name': 'Mouchoir', 'emoji': '🧻', 'category': 'general'},
    {'name': 'Chewing-gum', 'emoji': '🍬', 'category': 'general'},
    {'name': 'Ticket', 'emoji': '🎫', 'category': 'general'},
    {'name': 'Cigarette', 'emoji': '🚬', 'category': 'general'},
    {'name': 'Paille', 'emoji': '🥤', 'category': 'general'},
    {'name': 'Emballage sale', 'emoji': '🍟', 'category': 'general'},
    {'name': 'Masque', 'emoji': '😷', 'category': 'general'},
    {'name': 'Scotch', 'emoji': '📏', 'category': 'general'},
    {'name': 'Élastique', 'emoji': '🔗', 'category': 'general'},

    // Électroniques (12 items)
    {'name': 'Téléphone', 'emoji': '📱', 'category': 'electronic'},
    {'name': 'Batterie', 'emoji': '🔋', 'category': 'electronic'},
    {'name': 'Ordinateur', 'emoji': '💻', 'category': 'electronic'},
    {'name': 'Câble', 'emoji': '🔌', 'category': 'electronic'},
    {'name': 'Écouteurs', 'emoji': '🎧', 'category': 'electronic'},
    {'name': 'Montre', 'emoji': '⌚', 'category': 'electronic'},
    {'name': 'Clé USB', 'emoji': '💾', 'category': 'electronic'},
    {'name': 'Chargeur', 'emoji': '🔌', 'category': 'electronic'},
    {'name': 'Souris', 'emoji': '🖱️', 'category': 'electronic'},
    {'name': 'Clavier', 'emoji': '⌨️', 'category': 'electronic'},
    {'name': 'Ampoule', 'emoji': '💡', 'category': 'electronic'},
    {'name': 'Pile', 'emoji': '🔋', 'category': 'electronic'},
  ];

  late AnimationController _celebrationController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    animationTimer?.cancel();
    _celebrationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void startGame() {
    gameTimer = Timer.periodic(Duration(seconds: max(1, 4 - level ~/ 2)), (timer) {
      if (!isPaused && wastes.length < 5 && lives > 0) {
        addRandomWaste();
      }
    });

    animationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isPaused) {
        updateWastePositions();
      }
    });
  }

  void updateWastePositions() {
    setState(() {
      final screenHeight = MediaQuery.of(context).size.height;
      wastes.removeWhere((waste) {
        if (!waste.isDragging) {
          waste.position = Offset(waste.position.dx, waste.position.dy + waste.velocity);
          if (waste.position.dy > screenHeight - 200) {
            lives--;
            showFeedback('Déchet perdu! -1 vie', Colors.orange);
            if (lives <= 0) {
              gameOver();
            }
            return true;
          }
        }
        return false;
      });
    });
  }

  Future<void> saveGameResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      int oldScore = 0;
      int oldLevel = 1;
      int games = 0;

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        oldScore = (data['totalScore'] ?? 0) as int;
        oldLevel = (data['maxLevel'] ?? 1) as int;
        games = (data['gamesPlayed'] ?? 0) as int;
      }

      transaction.set(
        userRef,
        {
          'totalScore': oldScore + score,
          'maxLevel': level > oldLevel ? level : oldLevel,
          'gamesPlayed': games + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    await checkAndUnlockBadges(user.uid);
  }


  final List<Map<String, dynamic>> badgesConfig = [
    {'id': 'beginner', 'title': 'Débutant', 'emoji': '🌱', 'score': 50},
    {'id': 'protector', 'title': 'Protecteur', 'emoji': '🌿', 'score': 100},
    {'id': 'guardian', 'title': 'Gardien', 'emoji': '🌳', 'score': 200},
    {'id': 'hero', 'title': 'Héros', 'emoji': '🌍', 'score': 500},
    {'id': 'legend', 'title': 'Légende', 'emoji': '👑', 'score': 1000},
  ];


  Future<void> checkAndUnlockBadges(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final badgeRef = userRef.collection('badges');

    final userSnap = await userRef.get();
    final totalScore = userSnap['totalScore'] ?? 0;

    for (final badge in badgesConfig) {
      if (totalScore >= badge['score']) {
        await badgeRef.doc(badge['id']).set(
          {
            'title': badge['title'],
            'emoji': badge['emoji'],
            'unlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    }
  }


  void addRandomWaste() {
    final random = Random();
    final item = wasteItems[random.nextInt(wasteItems.length)];
    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      wastes.add(Waste(
        name: item['name']!,
        emoji: item['emoji']!,
        category: item['category']!,
        position: Offset(random.nextDouble() * (screenWidth - 80), 0),
        velocity: 2.0 + (level * 0.5),
      ));
    });
  }

  void checkAnswer(Waste waste, String binCategory) {
    setState(() {
      if (waste.category == binCategory) {
        score += 10 * level;
        _celebrationController.forward().then((_) => _celebrationController.reset());
        showFeedback('Bravo! +${10 * level}', Colors.green);

        if (score > 0 && score % 100 == 0) {
          level++;
          showLevelUp();
        }
      } else {
        lives--;
        _shakeController.forward().then((_) => _shakeController.reset());
        showFeedback('Oops! Mauvaise corbeille!', Colors.red);

        if (lives <= 0) {
          gameOver();
        }
      }
      wastes.remove(waste);
    });
  }

  void showLevelUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            Text('Niveau $level!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Tu deviens un expert du tri!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> gameOver() async {
    gameTimer?.cancel();
    animationTimer?.cancel();

    await  saveGameResult();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Fin du Jeu!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('Score Final: $score',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Niveau atteint: $level',
                style: const TextStyle(fontSize: 20, color: Colors.purple)),
            const SizedBox(height: 20),
            const Text('Continue à protéger notre planète!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Menu', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Rejouer', style: TextStyle(fontSize: 18,color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      lives = 3;
      level = 1;
      wastes.clear();
      isPaused = false;
    });
    startGame();
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity*0.98,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade100, Colors.green.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec stats
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        _buildStatCard('Score', score.toString(), Colors.blue, Icons.star),
                        const SizedBox(width: 8),
                        _buildStatCard('Vies', '❤️' * lives, Colors.red, Icons.favorite),
                        const SizedBox(width: 8),
                        _buildStatCard('Niveau', level.toString(), Colors.purple, Icons.trending_up),
                      ],
                    ),
                    IconButton(
                      icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 30),
                      onPressed: togglePause,
                    ),
                  ],
                ),
              ),

              // Zone de jeu
              Expanded(
                child: Stack(
                  children: [
                    ...wastes.map((waste) => _buildWasteItem(waste)),
                    if (isPaused)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Text(
                            'PAUSE',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Corbeilles
              Container(
                height: 140,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: bins
                        .map(
                          (bin) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildBin(bin),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteItem(Waste waste) {
    return Positioned(
      left: waste.position.dx,
      top: waste.position.dy,
      child: Draggable<Waste>(
        data: waste,
        feedback: _buildWasteWidget(waste, true),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildWasteWidget(waste, false),
        ),
        child: _buildWasteWidget(waste, false),
        onDragStarted: () {
          setState(() => waste.isDragging = true);
        },
        onDragEnd: (details) {
          setState(() => waste.isDragging = false);
        },
      ),
    );
  }

  Widget _buildWasteWidget(Waste waste, bool isDragging) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: isDragging ? 1.2 : scale,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDragging ? 0.4 : 0.2),
                  blurRadius: isDragging ? 15 : 8,
                  offset: Offset(0, isDragging ? 8 : 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                waste.emoji,
                style: TextStyle(fontSize: isDragging ? 40 : 35),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBin(Bin bin) {
    return DragTarget<Waste>(
      onWillAccept: (waste) => waste != null,
      onAccept: (waste) => checkAnswer(waste, bin.category),
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isHovering ? 85 : 75,
          height: isHovering ? 120 : 100,
          decoration: BoxDecoration(
            color: bin.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHovering ? Colors.white : Colors.transparent,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: bin.color.withOpacity(0.5),
                blurRadius: isHovering ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(bin.icon, color: Colors.white, size: isHovering ? 32 : 28),
              const SizedBox(height: 6),
              Text(
                bin.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isHovering ? 12 : 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}