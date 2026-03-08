import 'package:cloud_firestore/cloud_firestore.dart';


class Course {
  final String id;
  final String title;
  final String shortDescription;
  final String videoUrl;
  final DateTime createdAt;
  final List<ContentItem> contents;

  Course({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.videoUrl,
    required this.createdAt,
    required this.contents,
  });

  // Constructeur depuis Firestore
  factory Course.fromFirestore(Map<String, dynamic> data, String docId) {
    final contentList = (data['contents'] as List<dynamic>? ?? [])
        .map((e) => ContentItem.fromMap(e as Map<String, dynamic>))
        .toList();

    return Course(
      id: docId,
      title: data['title'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contents: contentList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'shortDescription': shortDescription,
      'videoUrl': videoUrl,
      'createdAt': createdAt,
      'contents': contents.map((c) => c.toMap()).toList(),
    };
  }
}

class ContentItem {
  final String type; // 'text' ou 'image'
  final String value;

  ContentItem({required this.type, required this.value});

  factory ContentItem.fromMap(Map<String, dynamic> map) {
    return ContentItem(
      type: map['type'] ?? 'text',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
    };
  }
}



class CourseContent {
  final String id;
  final String courseId;
  final String type; // "text" ou "image"
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;

  CourseContent({
    required this.id,
    required this.courseId,
    required this.type,
    this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory CourseContent.fromFirestore(Map<String, dynamic> data, String id) {
    return CourseContent(
      id: id,
      courseId: data['courseId'] ?? '',
      type: data['type'] ?? 'text',
      content: data['content'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'type': type,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}




enum QuestionType { radio, qcm, text }

class Quiz {
  final String id;
  final String courseId;
  final String titreQuizz;
  final String resume;
  final String question;
  final QuestionType type;
  final List<String> options;
  final int answer; // index de la bonne réponse

  Quiz({
    required this.id,
    required this.courseId,
    required this.titreQuizz,
    required this.resume,
    required this.question,
    required this.type,
    required this.options,
    required this.answer,
  });

  factory Quiz.fromFirestore(Map<String, dynamic> data, String id) {
    QuestionType parseType(String t) {
      switch (t.toLowerCase()) {
        case 'radio':
          return QuestionType.radio;
        case 'qcm':
          return QuestionType.qcm;
        default:
          return QuestionType.radio;
      }
    }

    return Quiz(
      id: id,
      courseId: data['courseId'] ?? '',
      titreQuizz: data['titreQuizz'] ?? '',
      resume: data['resume'] ?? '',
      question: data['question'] ?? '',
      type: parseType(data['type'] ?? 'radio'),
      options: List<String>.from(data['options'] ?? []),
      answer: data['answer'] ?? 0,
    );
  }
}

class Question {
  final int id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final dynamic correctAnswer; // String ou List<String>

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.correctAnswer,
  });

  factory Question.fromQuiz(Quiz q, int id) {
    dynamic correct;
    if (q.type == QuestionType.radio || q.type == QuestionType.text) {
      correct = q.options.isNotEmpty ? q.options[q.answer] : '';
    } else if (q.type == QuestionType.qcm) {
      correct = q.options[q.answer]; // simplifié ici
    }
    return Question(
      id: id,
      text: q.question,
      type: q.type,
      options: q.options,
      correctAnswer: correct,
    );
  }
}
