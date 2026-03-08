// INTERFACE ADULTE AMÉLIORÉE
// ============================================
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu/Connexion/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../Chat/start_chat.dart';
import '../Profile/ProfilePage.dart';
import '../QCM/quiz_page.dart';
import '../database/Cours.dart';
import '../enfant/startGame.dart';
import '../theme/colors.dart';

class AdultHomeScreen extends StatefulWidget {
  final AppUser user;

  const AdultHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AdultHomeScreen> createState() => _AdultHomeScreenState();
}

class _AdultHomeScreenState extends State<AdultHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (userId == null) {
      _pages = [
        const AdultFormationsPage(),
        const Center(
          child: Text(
            "Veuillez vous connecter pour voir votre progression",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        const startGame(),
       /* const StartChat(),*/
        ProfileScreen(user: widget.user),
      ];
    } else {
      _pages = [
        const AdultFormationsPage(),
        AdultProgressPage(userId: userId),
        const startGame(),
       /* const StartChat(),*/
        ProfileScreen(user: widget.user),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Formations'),
        backgroundColor: AppColors.bluebg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.bluebg,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Formations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progression',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'jeu',
          ),
       /*   BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class AdultFormationsPage extends StatefulWidget {
  const AdultFormationsPage({super.key});

  @override
  State<AdultFormationsPage> createState() => _AdultFormationsPageState();
}

class _AdultFormationsPageState extends State<AdultFormationsPage> {
  String? _currentCourseId; // Pour tracker le cours actuellement affiché

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Gestion des erreurs
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Impossible de charger les formations',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune formation disponible',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revenez plus tard pour découvrir nos formations',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final courses = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: () async {
              // Force le rechargement
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final doc = courses[index];
                final courseId = doc.id;
                final courseData = doc.data() as Map<String, dynamic>;

                // Récupérer la liste des contenus depuis Firestore
                final List contents = courseData['contents'] ?? [];

                // Trouver la première image
                String imageUrl = '';
                for (var content in contents) {
                  if (content['type'] == 'image') {
                    imageUrl = content['value'] ?? '';
                    break;
                  }
                }

                // Si pas d'image dans contents, vérifier imageUrl direct
                if (imageUrl.isEmpty) {
                  imageUrl = courseData['imageUrl'] ?? '';
                }

                return _CourseCard(
                  courseId: courseId,
                  courseData: courseData,
                  imageUrl: imageUrl,
                  onTap: () {
                    setState(() {
                      _currentCourseId = courseId;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormationDetailPage(
                          courseId: courseId,
                          courseData: courseData,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

}

class _CourseCard extends StatelessWidget {
  final String courseId;
  final Map<String, dynamic> courseData;
  final String imageUrl;
  final VoidCallback? onTap;

  const _CourseCard({
    required this.courseId,
    required this.courseData,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = courseData['title'] ?? 'Sans titre';
    final description = courseData['shortDescription'] ??
        courseData['description'] ??
        'Aucune description';
    final videoUrl = courseData['videoUrl'] as String?;
    final category = courseData['category'] ?? 'Général';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormationDetailPage(
                courseId: courseId,
                courseData: courseData,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture
            if (imageUrl.isNotEmpty || videoUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildMediaThumbnail(imageUrl, videoUrl),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: WidgetStatePropertyAll(AppColors.orange),
                        labelStyle: TextStyle(color: Colors.white),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(String? imageUrl, String? videoUrl) {
    // Si on a une image
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(hasVideo: videoUrl != null && videoUrl.isNotEmpty);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    // Sinon, placeholder
    return _buildPlaceholder(hasVideo: videoUrl != null && videoUrl.isNotEmpty);
  }

  Widget _buildPlaceholder({required bool hasVideo}) {
    return Container(
      height: 180,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          hasVideo ? Icons.play_circle_filled : Icons.school,
          size: 60,
          color: hasVideo ? Colors.black87 : Colors.grey[600],
        ),
      ),
    );
  }
}

class FormationDetailPage extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> courseData;

  const FormationDetailPage({
    super.key,
    required this.courseId,
    required this.courseData,
  });

  @override
  State<FormationDetailPage> createState() => _FormationDetailPageState();
}

class _FormationDetailPageState extends State<FormationDetailPage> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _markCourseAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    if (userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('readCourses')
          .doc(widget.courseId)
          .set({'readAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print("Erreur lors du marquage du cours comme lu: $e");
    }
  }

  // --- Ouvrir le quiz et charger depuis Firestore ---
  void _openQuiz() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('quizzes')
        .get();

    final quizData = snapshot.docs.map((doc) {
      final data = doc.data();
      return Question(
        id: int.tryParse(doc.id) ?? 0,
        text: data['question'] ?? '',
        type: data['type'] == 'qcm'
            ? QuestionType.qcm
            : data['type'] == 'radio'
            ? QuestionType.radio
            : QuestionType.text,
        options: List<String>.from(data['options'] ?? []),
        correctAnswer: data['answer'] ?? '',
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          courseId:widget.courseId,
          quizData: quizData,
          userId: userId,
        ),
      ),
    );
  }


  void _initializeVideo() {
    final videoUrl = widget.courseData['videoUrl'] as String?;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _hasVideoError = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.courseData['title'] ?? 'Formation';
    final description = widget.courseData['shortDescription'] ??
        widget.courseData['description'] ??
        'Aucune description disponible';
    final category = widget.courseData['category'] ?? 'Général';
    final contents = widget.courseData['contents'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.bluebg,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lecteur vidéo
            _buildVideoPlayer(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Catégorie
                  Chip(
                    label: Text(category),
                    backgroundColor: AppColors.bluebg.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppColors.bluebg,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contenu du cours
                  if (contents.isNotEmpty) ...[
                    const Text(
                      'Contenu du cours',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...contents.map((content) {
                      final type = content['type'] ?? 'text';
                      final value = content['value'] ?? '';

                      if (type == 'text') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        );
                      } else if (type == 'image' && value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              value,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                    const SizedBox(height: 24),
                  ],

                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.courseId != null
          ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bouton Marquer comme lu
          FloatingActionButton(
            heroTag: 'mark_read',
            onPressed: () => _markCourseAsRead(),
            backgroundColor: const Color(0xFF2E7D32),
            child: const Icon(Icons.check_circle, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Bouton Quiz
          FloatingActionButton(
            heroTag: 'quiz',
            onPressed: () => _openQuiz(),
            backgroundColor: AppColors.orange,
            child: const Icon(Icons.quiz, color: Colors.white),
          ),
        ],
      )
          : null,
    );


  }

  Widget _buildVideoPlayer() {
    if (_hasVideoError) {
      return Container(
        height: 220,
        color: Colors.black87,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text(
                'Erreur de chargement de la vidéo',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isVideoInitialized || _controller == null) {
      return Container(
        height: 220,
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          Positioned(
            child: IconButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              icon: Icon(
                _controller!.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 64,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class AdultProgressPage extends StatelessWidget {
  final String userId;

  const AdultProgressPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Validation du userId
    if (userId.isEmpty) {
      return const Center(
        child: Text(
          'Erreur: Utilisateur non identifié',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    final coursesRef = FirebaseFirestore.instance
        .collection('courses') // <-- ta collection Firestore
        .orderBy('createdAt', descending: false);

    final resultsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quizResults');

    return StreamBuilder<QuerySnapshot>(
      stream: coursesRef.snapshots(),
      builder: (context, courseSnap) {
        // Gestion d'erreur détaillée
        if (courseSnap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de chargement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  courseSnap.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Force le rebuild
                    (context as Element).markNeedsBuild();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (courseSnap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement de votre progression...'),
              ],
            ),
          );
        }

        final courses = courseSnap.data?.docs ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: resultsRef.snapshots(),
          builder: (context, resultSnap) {
            if (resultSnap.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Erreur de chargement des résultats'),
                    const SizedBox(height: 8),
                    Text(
                      resultSnap.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            }

            if (resultSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final completedCourseIds =
                resultSnap.data?.docs.map((d) => d.id).toSet() ?? {};

            final completed = courses
                .where((c) => completedCourseIds.contains(c.id))
                .toList();

            final inProgress = courses
                .where((c) => !completedCourseIds.contains(c.id))
                .toList();

            final totalCourses = courses.length;
            final completedCount = completed.length;
            final progressPercentage = totalCourses > 0
                ? (completedCount / totalCourses * 100).toInt()
                : 0;

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: const Text(
                        'Ma progression',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),

                    // Progression globale
                    _buildOverallProgress(
                      context,
                      progressPercentage,
                      completedCount,
                      totalCourses,
                    ),
                    SizedBox(height:  MediaQuery.of(context).size.height*0.01),

                    // Statistiques
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Complétés',
                            completedCount.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'En cours',
                            inProgress.length.toString(),
                            Icons.timelapse,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height:  MediaQuery.of(context).size.height*0.02),

                    // Liste des cours
                    if (courses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucun cours disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Les cours seront bientôt disponibles',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: const Text(
                          'Détails des formations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...courses.map((course) {
                        try {
                          final courseData = course.data() as Map<String, dynamic>?;

                          if (courseData == null) {
                            return const SizedBox.shrink();
                          }

                          final isDone = completedCourseIds.contains(course.id);
                          final title = courseData['title'] as String? ?? 'Sans titre';

                          return _progressItem(
                            title: title,
                            progress: isDone ? 1.0 : 0.0,
                            isDone: isDone,
                          );
                        } catch (e) {
                          print('Erreur lors du chargement du cours ${course.id}: $e');
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverallProgress(
      BuildContext context,
      int percentage,
      int completed,
      int total,
      ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.bluebg,
              AppColors.bluebg.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression globale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$completed sur $total formations terminées',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressItem({
    required String title,
    required double progress,
    required bool isDone,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  color: isDone ? Colors.green : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDone ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDone ? '✓ Terminé' : 'À commencer',
              style: TextStyle(
                fontSize: 13,
                color: isDone ? Colors.green : Colors.grey[600],
                fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}