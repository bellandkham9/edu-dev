import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu/QCM/results_page.dart';
import 'package:flutter/material.dart';

import '../database/Cours.dart';

class QuizPage extends StatefulWidget {
  final String courseId;
  final List<Question> quizData;
  final String userId;

  const QuizPage({
    super.key,
    required this.courseId,
    required this.quizData,
    required this.userId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Map<int, dynamic> _userSelections = {};
  bool _isCgvAccepted = false;

  void _handleRadioChange(int id, String? value) => setState(() => _userSelections[id] = value);

  void _handleCheckboxChange(int id, String option, bool checked) {
    setState(() {
      if (!_userSelections.containsKey(id)) _userSelections[id] = <String>[];
      List<String> selected = _userSelections[id];
      if (checked) {
        if (!selected.contains(option)) selected.add(option);
      } else {
        selected.remove(option);
      }
    });
  }

  void _handleTextChange(int id, String value) => _userSelections[id] = value;

  bool _isAnswerCorrect(Question question, dynamic userAnswer) {
    if (question.type == QuestionType.text) {
      return (userAnswer as String?)?.trim().toLowerCase() ==
          question.correctAnswer.trim().toLowerCase();
    } else if (question.type == QuestionType.radio) {
      return userAnswer == question.correctAnswer;
    } else if (question.type == QuestionType.qcm) {
      final correct = question.correctAnswer.split(',').map((e) => e.trim()).toList();
      final selected = (userAnswer as List<String>? ?? []);
      return selected.toSet().containsAll(correct) && correct.toSet().containsAll(selected);
    }
    return false;
  }

  Future<void> _submitQuiz() async {
    if (!_isCgvAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez accepter les CGV avant de continuer.")),
      );
      return;
    }

    int correctAnswers = 0;
    for (var q in widget.quizData) {
      final userAnswer = _userSelections[q.id];
      if (_isAnswerCorrect(q, userAnswer)) correctAnswers++;
    }
    final double score = (correctAnswers / widget.quizData.length) * 100;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('quizResults')
        .doc(widget.courseId)
        .set({
      'answers': _userSelections.map((key, value) => MapEntry(key.toString(), value)),
      'score': score,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsPage(
          quizData: widget.quizData,
          userAnswers: _userSelections,
          score: score,
        ),
      ),
    );
  }

  Future<Map<String, String>?> fetchQuizMeta(String courseId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('quizzes')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();

    if (!data.containsKey('titreQuizz') || !data.containsKey('resume')) return null;

    return {
      'titreQuizz': data['titreQuizz'],
      'resume': data['resume'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz"),
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Affichage du titre et résumé une seule fois
          FutureBuilder<Map<String, String>?>(
            future: fetchQuizMeta(widget.courseId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox(); // aucun titre/résumé
              }
              return QuizHeaderCard(
                titre: snapshot.data!['titreQuizz']!,
                resume: snapshot.data!['resume']!,
              );
            },
          ),

          const SizedBox(height: 16),

          // Liste des questions
          ...widget.quizData.map((q) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${q.id}. ${q.text}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (q.type == QuestionType.radio)
                    ...q.options.map((opt) {
                      final selected = _userSelections[q.id] as String?;
                      return RadioListTile<String>(
                        value: opt,
                        groupValue: selected,
                        onChanged: (v) => _handleRadioChange(q.id, v),
                        title: Text(opt),
                      );
                    }),
                  if (q.type == QuestionType.qcm)
                    ...q.options.map((opt) {
                      final selected = _userSelections[q.id] as List<String>? ?? [];
                      final checked = selected.contains(opt);
                      return CheckboxListTile(
                        value: checked,
                        onChanged: (v) => _handleCheckboxChange(q.id, opt, v ?? false),
                        title: Text(opt),
                      );
                    }),
                  if (q.type == QuestionType.text)
                    TextFormField(
                      onChanged: (v) => _handleTextChange(q.id, v),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Votre réponse",
                      ),
                    ),
                ],
              ),
            );
          }).toList(),

          Row(
            children: [
              Checkbox(
                value: _isCgvAccepted,
                onChanged: (v) => setState(() => _isCgvAccepted = v ?? false),
                activeColor: Colors.orange,
              ),
              const Expanded(child: Text("J'ai lu et j'accepte les conditions du quiz.")),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _submitQuiz,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Soumettre", style: TextStyle(fontSize: 18,color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizHeaderCard extends StatelessWidget {
  final String titre;
  final String resume;

  const QuizHeaderCard({
    super.key,
    required this.titre,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Quiz",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            titre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            resume,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
