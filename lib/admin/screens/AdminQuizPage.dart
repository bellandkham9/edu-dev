import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../database/Cours.dart';

class AdminQuizPage extends StatefulWidget {
  final String courseId;

  const AdminQuizPage({super.key, required this.courseId});

  @override
  State<AdminQuizPage> createState() => _AdminQuizPageState();
}

class _AdminQuizPageState extends State<AdminQuizPage> {
  final _formKey = GlobalKey<FormState>();

  bool quizMetaExists = false;
  bool isLoading = true;


  String questionText = '';
  String titreQuizz = '';
  String resume = '';
  QuestionType selectedType = QuestionType.text;
  List<String> options = [];
  List<String> correctOptions = [];

  final TextEditingController _optionController = TextEditingController();

  void _addOption() {
    final text = _optionController.text.trim();
    if (text.isNotEmpty && !options.contains(text)) {
      setState(() {
        options.add(text);
        _optionController.clear();
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkQuizMeta();
  }
  Future<void> _checkQuizMeta() async {
    final quizzesRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('quizzes');

    final snapshot = await quizzesRef.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      if (data.containsKey('titreQuizz') && data.containsKey('resume')) {
        quizMetaExists = true;
      }
    }

    setState(() {
      isLoading = false;
    });
  }


   _removeOption(String option) {
    setState(() {
      options.remove(option);
      correctOptions.remove(option); // Retire si c'était coché
    });
  }

  void _toggleCorrectOption(String option, bool selected) {
    setState(() {
      if (selected) {
        if (!correctOptions.contains(option)) correctOptions.add(option);
      } else {
        correctOptions.remove(option);
      }
    });
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      if ((selectedType == QuestionType.radio || selectedType == QuestionType.qcm) &&
          options.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Ajoutez au moins une option.")));
        return;
      }

      if ((selectedType == QuestionType.radio || selectedType == QuestionType.qcm) &&
          correctOptions.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Sélectionnez la ou les bonnes réponses.")));
        return;
      }

      // Déterminer la réponse correcte pour Firestore
      String answer;
      if (selectedType == QuestionType.text) {
        answer = correctOptions.isNotEmpty ? correctOptions.first : '';
      } else if (selectedType == QuestionType.radio) {
        answer = correctOptions.first;
      } else {
        answer = correctOptions.join(','); // QCM
      }

      final quizzesRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('quizzes');

// 1️⃣ Récupérer les questions existantes
      final snapshot = await quizzesRef.get();

// 2️⃣ Calculer le numéro de la question
      final questionNumber = snapshot.docs.length + 1;

// 3️⃣ Ajouter la question
      final data = {
        'question': questionText,
        'type': selectedType.name,
        'options': options,
        'answer': answer,
        'createdAt': FieldValue.serverTimestamp(),
      };

// Ajouter titre + résumé UNE SEULE FOIS
      if (!quizMetaExists) {
        data['titreQuizz'] = titreQuizz;
        data['resume'] = resume;
      }

      await quizzesRef
          .doc(questionNumber.toString())
          .set(data);


      setState(() {
        questionText = '';
        selectedType = QuestionType.text;
        options = [];
        correctOptions = [];
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Question ajoutée avec succès !")));

      setState(() {
        quizMetaExists = true;
      });


    }
  }

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title:  Text("Admin Quiz",style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              if (!quizMetaExists) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Titre du Quiz",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => titreQuizz = val,
                  validator: (val) =>
                  val == null || val.isEmpty ? "Entrez le titre du quiz" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Résumé du Quiz",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (val) => resume = val,
                  validator: (val) =>
                  val == null || val.isEmpty ? "Entrez le résumé du quiz" : null,
                ),
                const SizedBox(height: 16),
              ],


              // Question
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Texte de la question",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (val) => questionText = val,
                validator: (val) => val == null || val.isEmpty ? "Entrez une question" : null,
              ),
              const SizedBox(height: 12),

              // Type de question
              DropdownButtonFormField<QuestionType>(
                value: selectedType,
                items: QuestionType.values
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                ))
                    .toList(),
                onChanged: (val) => setState(() => selectedType = val!),
                decoration: const InputDecoration(
                  labelText: "Type de question",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Options si QCM ou Radio
              if (selectedType == QuestionType.radio || selectedType == QuestionType.qcm)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Options"),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _optionController,
                            decoration: const InputDecoration(
                              hintText: "Ajouter une option",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.orange),
                          onPressed: _addOption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Liste des options avec suppression
                    Column(
                      children: options.map((opt) {
                        return Row(
                          children: [
                            Expanded(child: Text(opt)), // Affiche juste le texte de l'option
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeOption(opt), // 🔹 closure
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Choix correct (radio ou checkbox)
                    Column(
                      children: options.map((opt) {
                        return Row(
                          children: [
                            if (selectedType == QuestionType.radio)
                              Radio<String>(
                                value: opt,
                                groupValue: correctOptions.isNotEmpty ? correctOptions.first : null,
                                onChanged: (v) => _toggleCorrectOption(opt, true),
                              ),
                            if (selectedType == QuestionType.qcm)
                              Checkbox(
                                value: correctOptions.contains(opt),
                                onChanged: (v) => _toggleCorrectOption(opt, v ?? false),
                              ),
                            Text(opt),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveQuestion,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Ajouter la question", style: TextStyle(fontSize: 18,color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
