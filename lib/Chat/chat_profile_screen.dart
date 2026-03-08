import 'package:flutter/material.dart';
import 'start_chat.dart';

class ChatProfileScreen extends StatelessWidget {
  final Conversation conversation;

  const ChatProfileScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final Participant? participant =
    conversation.participants.isNotEmpty ? conversation.participants[0] : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade300,
              child: participant != null
                  ? Text(participant.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))
                  : const Icon(Icons.person, size: 40, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Text(conversation.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(participant != null ? participant.name : 'Participant non disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
