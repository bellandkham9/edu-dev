import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_list_screen.dart';
import 'message_screen.dart';

class StartChat extends StatelessWidget {
  const StartChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      initialRoute: '/conversations',
      routes: {
        '/conversations': (context) => const ChatListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/message') {
          final conversationId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(conversationId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Scaffold(
                      body: Center(child: Text('Conversation non trouvée')),
                    );
                  }

                  final conversationDoc = snapshot.data!;
                  final conversation = Conversation.fromFirestore(conversationDoc);

                  return MessageScreen(conversation: conversation);
                },
              );
            },
          );
        }
        return null;
      },
    );
  }
}

// --------------------
// Modèles de données
// --------------------

enum MessageDirection { sent, received }

class Conversation {
  final String id;
  final String title;
  final String type; // 'private' ou 'group'
  final DateTime createdAt;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String avatarUrl;
  final List<Participant> participants;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    this.lastMessage = '',
    this.lastMessageAt,
    this.avatarUrl = '',
    this.participants = const [],
    this.messages = const [],
  });

  static Conversation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      title: data['title'] ?? 'Conversation',
      type: data['type'] ?? 'private',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      avatarUrl: data['avatarUrl'] ?? '',
      participants: [], // charger séparément si besoin
      messages: [], // charger séparément si besoin
    );
  }
}

class Participant {
  final String uid;
  final String name;

  Participant({required this.uid, required this.name});

  static Participant fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Participant(
      uid: data['uid'],
      name: data['name'] ?? '',
    );
  }
}

enum MessageType { text, image, video, audio }
class Message {
  final String id;
  final String senderId;
  final String content; // texte ou URL média
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
  final MessageDirection direction;
  final String ?caption;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.direction,
    required this.isRead,
    required this.caption,
  });

  factory Message.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;
    final type = MessageType.values.firstWhere(
          (e) => e.name == (data['type'] ?? 'text'),
      orElse: () => MessageType.text,
    );
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final direction = data['senderId'] == currentUserId
        ? MessageDirection.sent
        : MessageDirection.received;

    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      type: type,
      isRead: data['isRead'] ?? false,
      createdAt: createdAt,
      direction: direction,
      caption: data['caption'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'caption': caption,
      'isRead': false, // 👈 IMPORTANT
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

}

