// results_page.dart

import 'package:flutter/material.dart';
import '../database/Cours.dart';
import 'quiz_page.dart';

class ResultsPage extends StatelessWidget {
  final List<Question> quizData;
  final Map<int, dynamic> userAnswers;
  final double score;

  const ResultsPage({
    super.key,
    required this.quizData,
    required this.userAnswers,
    required this.score,
  });

  // Vérifie si la réponse est correcte
  bool _isAnswerCorrect(Question question, dynamic userAnswer) {
    if (question.type == QuestionType.text) {
      return (userAnswer as String).trim().toLowerCase() ==
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

  Color _getFeedbackColor(bool isCorrect) {
    return isCorrect ? Colors.green.shade100 : Colors.red.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text("Résultats 🏆"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildScoreSection(context),
          const SizedBox(height: 20),
          ...quizData.map((q) => _buildCorrectionWidget(q, userAnswers[q.id])).toList(),
          const SizedBox(height: 30),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // Section du score
  Widget _buildScoreSection(BuildContext context) {
    final bool isSuccess = score >= 70;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Votre score',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // Correction détaillée
  Widget _buildCorrectionWidget(Question question, dynamic userAnswer) {
    final isCorrect = _isAnswerCorrect(question, userAnswer);
    final feedbackText = isCorrect ? "Correct ✅" : "Incorrect ❌";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getFeedbackColor(isCorrect),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${question.id}. ${question.text}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (question.type != QuestionType.text)
            ...question.options.map((option) {
              final bool selected = (userAnswer is List)
                  ? userAnswer.contains(option)
                  : userAnswer == option;
              final bool correctOption = option == question.correctAnswer;
              Icon icon;
              if (selected && correctOption) {
                icon = const Icon(Icons.check_circle, color: Colors.green);
              } else if (selected && !correctOption) {
                icon = const Icon(Icons.cancel, color: Colors.red);
              } else if (!selected && correctOption) {
                icon = const Icon(Icons.check_circle_outline, color: Colors.green);
              } else {
                icon = const Icon(Icons.circle_outlined, color: Colors.grey);
              }
              return ListTile(
                leading: icon,
                title: Text(option, style: TextStyle(fontWeight: correctOption ? FontWeight.bold : FontWeight.normal)),
                dense: true,
              );
            }).toList(),
          if (question.type == QuestionType.text)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Votre réponse: ${userAnswer ?? ""}'),
                  const SizedBox(height: 4),
                  if (!isCorrect) Text('Réponse correcte: ${question.correctAnswer}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(feedbackText, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Boutons “Recommencer” et “Retour”
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuizPage(quizData: quizData, courseId: '', userId: '',),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Recommencer'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Retourner au cours'),
        ),
      ],
    );
  }
}
