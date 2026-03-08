// chat_list_screen.dart

/*

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/top_search_bar.dart';
import 'start_chat.dart';


class ChatListScreen extends StatelessWidget {
  final List<Chat> chats;
  const ChatListScreen({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children:  [
                SizedBox(height: MediaQuery.of(context).size.height*0.15,),
                Expanded(child: TopSearchBar(menuHint: false,)),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 80, color: Colors.white,),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatListItem(context, chat);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.edit, color: Colors.white),
      ),

    );
  }

  Widget _buildChatListItem(BuildContext context, Chat chat) {
    return ListTile(
      onTap: () {
        // Naviguer vers l'écran de message
        Navigator.of(context).pushNamed('/message', arguments: chat);
      },
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade300,

        backgroundImage: chat.avatarUrl.isNotEmpty
            ? AssetImage(chat.avatarUrl)       // netWork pur les cas des  Photo en line... si disponible
            : null,                               // Sinon on utilise la lettre

        child: (chat.avatarUrl.isEmpty)
            ? Text(
          chat.name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        )
            : null,  // Si photo présente → pas de texte
      )
      ,
      title: Text(chat.name, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chat.lastMessage, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(chat.time, style: TextStyle(fontSize: 12, color: chat.unreadCount > 0 ? Colors.green : Colors.grey)),
          if (chat.unreadCount > 0) ...[
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.green,
              // Utilisation d'un widget générique pour l'avatar.
              // En prod, vous utiliseriez Image.network ou Image.asset.
              child: Text(
                chat.unreadCount.toString(),
                style:  TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              )
            ),

          ]

        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Connexion/User.dart';
import '../theme/colors.dart';
import '../widgets/top_search_bar.dart';
import 'start_chat.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatsRef = FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: currentUser.uid);

    return Scaffold(
      body: Column(
        children: [

          SizedBox(height: 20,),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TopSearchBar(menuHint: false),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucune conversation"));
                }

                final conversations = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Conversation(
                    id: doc.id,
                    title: data['title'] ?? 'Discussion',
                    type: data['type'] ?? 'private',
                    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    lastMessage: data['lastMessage'] ?? '',
                    lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
                    avatarUrl: data['avatarUrl'] ?? '',
                    participants: [],
                    messages: [],
                  );
                }).toList();


                return ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) =>
                      _buildConversationItem(context, conversations[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () async {
          final currentUser = FirebaseAuth.instance.currentUser!;
          final result = await _showNewConversationDialog(
            context,
            currentUser.uid,
          );

          if (result != null) {
            final chatId = await _createOrGetPrivateConversation(
              currentUserId: currentUser.uid,
              otherUserId: result['userId']!,
              title: result['title']!,
            );

            Navigator.pushNamed(context, '/message', arguments: chatId);
          }
        },
      ),
    );
  }

  // -------------------
  // Méthode pour afficher le dialogue de création
  // -------------------
  Future<Map<String, String>?> _showNewConversationDialog(
    BuildContext context,
    String currentUserId,
  ) async {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        String selectedUserId = '';
        String chatTitle = '';
        List<AppUser> usersList = [];
        List<AppUser> filteredList = [];

        return StatefulBuilder(
          builder: (context, setState) {
            if (usersList.isEmpty) {
              FirebaseFirestore.instance.collection('users').get().then((
                snapshot,
              ) {
                final list = snapshot.docs
                    .map((doc) => AppUser.fromFirestore(doc))
                    .toList();
                setState(() {
                  usersList = list
                      .where((u) => u.uid != currentUserId)
                      .toList();
                  filteredList = usersList;
                });
              });
            }

            return AlertDialog(
              title: const Text('Nouvelle conversation'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Titre de la conversation',
                      ),
                      onChanged: (value) => chatTitle = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Rechercher un utilisateur',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        setState(() {
                          filteredList = usersList
                              .where(
                                (u) => u.fullName.toLowerCase().contains(
                                  query.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: filteredList.isEmpty
                          ? const Center(child: Text('Aucun utilisateur trouvé'))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final user = filteredList[index];
                                return ListTile(
                                  title: Text(user.fullName),
                                  selected: selectedUserId == user.uid,

                                  onTap: () {
                                    selectedUserId = user.uid;
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedUserId.isNotEmpty && chatTitle.isNotEmpty) {
                      Navigator.pop(context, {
                        'userId': selectedUserId,
                        'title': chatTitle,
                      });
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------
  // Méthode pour créer ou récupérer une conversation privée
  // -------------------
  Future<String> _createOrGetPrivateConversation({
    required String currentUserId,
    required String otherUserId,
    required String title,
  }) async {
    final convRef = FirebaseFirestore.instance.collection('conversations');

    final existing = await convRef
        .where('type', isEqualTo: 'private')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (final doc in existing.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUserId)) return doc.id;
    }

    final docRef = await convRef.add({
      'title': title,
      'type': 'private',
      'participants': [currentUserId, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'avatarUrl': '',
    });

    return docRef.id;
  }

  Stream<int> unreadCountStream(String conversationId) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }


  Widget _buildConversationItem(BuildContext context, Conversation conv) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final time = conv.lastMessageAt != null
        ? "${conv.lastMessageAt!.hour.toString().padLeft(2, '0')}:${conv.lastMessageAt!.minute.toString().padLeft(2, '0')}"
        : '';

    final participantRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conv.id)
        .collection('participants')
        .doc(currentUser.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: participantRef.snapshots(),
      builder: (context, snap) {
        DateTime? lastReadAt;

        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>;
          lastReadAt = (data['lastReadAt'] as Timestamp?)?.toDate();
        }

        return ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/message', arguments: conv.id);
          },
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade300,
            child: conv.avatarUrl.isEmpty
                ? Text(
              conv.title[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          title: Text(
            conv.title,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            conv.lastMessage,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 4),
              StreamBuilder<int>(
                stream: unreadCountStream(conv.id),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;

                  if (count == 0) {
                    return Text(time, style: TextStyle(fontSize: 12, color: Colors.grey));
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(time,
                          style: const TextStyle(fontSize: 12, color: Colors.green)),
                      const SizedBox(height: 4),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green,
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            ],
          ),
        );
      },
    );
  }



}
