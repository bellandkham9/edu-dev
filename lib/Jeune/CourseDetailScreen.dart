import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu/database/Cours.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../QCM/quiz_page.dart';
import '../theme/colors.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late VideoPlayerController _controller;
  late VoidCallback _listener;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.course.videoUrl)
      ..initialize().then((_) => setState(() {}));

    _listener = () => setState(() {});
    _controller.addListener(_listener);
    _startHideTimer();
    _markCourseAsRead();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _showControls = false);
    });
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() => _showControls = true);
    _startHideTimer();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return '${d.inHours > 0 ? '${two(d.inHours)}:' : ''}$minutes:$seconds';
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
          .doc(widget.course.id)
          .set({'readAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print("Erreur lors du marquage du cours comme lu: $e");
    }
  }

  void _openQuiz() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.course.id)
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
          courseId: widget.course.id,
          quizData: quizData,
          userId: userId,
        ),
      ),
    );
  }

  Widget _buildControls() {
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _showControls ? 1 : 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white)),
              Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.cast, color: Colors.white)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.white)),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  final newPos =
                      _controller.value.position - const Duration(seconds: 15);
                  _controller.seekTo(newPos > Duration.zero ? newPos : Duration.zero);
                },
                icon: const Icon(Icons.replay_10, size: 36, color: Colors.white),
              ),
              GestureDetector(
                onTap: _togglePlayPause,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black38,
                  child: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final newPos =
                      _controller.value.position + const Duration(seconds: 15);
                  final dur = _controller.value.duration;
                  _controller.seekTo(newPos < dur ? newPos : dur);
                },
                icon: const Icon(Icons.forward_10, size: 36, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Text(_formatDuration(position),
                    style: const TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    activeColor: Colors.green,
                    inactiveColor: Colors.white24,
                    value: (duration.inMilliseconds == 0)
                        ? 0
                        : position.inMilliseconds
                        .clamp(0, duration.inMilliseconds)
                        .toDouble(),
                    max: (duration.inMilliseconds == 0)
                        ? 1
                        : duration.inMilliseconds.toDouble(),
                    onChanged: (v) {
                      _controller.seekTo(Duration(milliseconds: v.toInt()));
                    },
                  ),
                ),
                Text(_formatDuration(duration),
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        title: Text(widget.course.title),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                /// 🎥 VIDEO
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _showControls = !_showControls);
                      if (_showControls) _startHideTimer();
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.black,
                          child: _controller.value.isInitialized
                              ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                              : const SizedBox(
                            height: 200,
                            child: ColoredBox(color: Colors.black12),
                          ),
                        ),

                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black26, Colors.transparent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.center,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 220,
                          child: _buildControls(),
                        ),
                      ],
                    ),
                  ),
                ),

                /// 📚 CONTENU DU COURS
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          widget.course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          widget.course.shortDescription,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 16),

                        ...widget.course.contents.map((c) {
                          if (c.type == 'text') {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                c.value,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            );
                          } else if (c.type == 'image') {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Image.network(
                                c.value,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 50),
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOUTON QUIZ
          Positioned(
            right: 16,
            bottom: 50,
            child: FloatingActionButton(
              onPressed: _openQuiz,
              backgroundColor: AppColors.orange,
              child: const Icon(Icons.quiz, color: Colors.white),
            ),
          ),

          // BOUTON MARQUER LU
          Positioned(
            right: 16,
            bottom: 120,
            child: FloatingActionButton(
              onPressed: () {
                _markCourseAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cours marqué comme lu")));
              },
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(Icons.mark_chat_read, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }



}