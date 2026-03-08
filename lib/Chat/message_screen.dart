import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import 'start_chat.dart';

class MessageScreen extends StatefulWidget {
  final Conversation conversation;

  MessageScreen({super.key, required this.conversation});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;



  @override
  Widget build(BuildContext context) {
    final Participant? participant =
    widget.conversation.participants.isNotEmpty ? widget.conversation.participants[0] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
/*            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              child: participant != null
                  ? Text(
                participant.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
                  : const Icon(Icons.person, size: 22),
            ),*/
            const SizedBox(width: 8),
            Text(
              widget.conversation.title,
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Conversation commencée le ${_formatConversationDate(widget.conversation.createdAt)}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversation.id)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final messageDate =
                        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final typeString = data['type'] ?? 'text';
                    final MessageType type = MessageType.values.firstWhere(
                          (e) => e.name == typeString,
                      orElse: () => MessageType.text,
                    );

                    final message = Message(
                      id: doc.id,
                      senderId: data['senderId'] ?? '',
                      content: data['content'] ?? '',
                      type: type,
                      direction: data['senderId'] == currentUser!.uid
                          ? MessageDirection.sent
                          : MessageDirection.received,
                      createdAt: messageDate,
                      caption: data['caption'] ?? '',
                      isRead: data['isRead'] ?? false,
                    );

                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Marquer comme lu dès l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
    });
  }
  Future<String> uploadFile(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<File?> pickFile(FileType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
    );

    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      return File(result.files.first.path!);
    }
    return null;
  }


  String _formatConversationDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }


  Future<void> _markMessagesAsRead() async {
    final uid = currentUser!.uid;

    final unreadMessages = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversation.id)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: uid)
        .get();

    for (final doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }




  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == currentUser?.uid;

    Widget bubbleContent;

    if (message.type == MessageType.image) {
      bubbleContent = SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                message.content,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),

            if (message.caption != null && message.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                child: Text(
                  message.caption!,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 6, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildTime(message.createdAt, message.direction),
                  const SizedBox(width: 4),

                  if (isMe)
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      color: message.isRead ? Colors.blue : Colors.grey,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      bubbleContent = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildTime(message.createdAt, message.direction),
              const SizedBox(width: 4),

              if (isMe)
                Icon(
                  message.isRead ? Icons.done_all : Icons.done,
                  size: 16,
                  color: message.isRead ? Colors.blue : Colors.grey,
                ),
            ],
          ),
        ],
      );
    }

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width*0.5,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: message.type == MessageType.image
            ? const EdgeInsets.all(2)
            : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.green : Colors.grey.shade300,
          borderRadius: message.type == MessageType.image
              ? const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          )
              : BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: bubbleContent,
      ),
    );
  }

  Widget _buildTime(DateTime date, MessageDirection direction) {
    return Text(
      DateFormat('HH:mm').format(date),
      style: TextStyle(
        fontSize: 10,
        color: direction == MessageDirection.sent
            ? Colors.white.withOpacity(0.7)
            : Colors.black54,
      ),
    );
  }

  Future<String?> uploadToCloudinary(File file) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/dltpbxntn/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = "UPLOAD_PRESET"
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(resBody);
      return data['secure_url'];
    } else {
      debugPrint("Cloudinary error: $resBody");
      return null;
    }
  }

  Future<void> _sendMessage({File? image}) async {
    String text = _messageController.text.trim();
    MessageType type = MessageType.text;
    String content = text;
    String? caption;

    if (image != null) {
      final url = await uploadToCloudinary(image);
      if (url == null) return;

      content = url;
      caption = text.isNotEmpty ? text : null;
      type = MessageType.image;
    }

    if (content.isEmpty) return;

    final msg = Message(
      id: '',
      senderId: currentUser!.uid,
      content: content,
      caption: caption,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      direction: MessageDirection.sent,
    );

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversation.id)
        .collection('messages')
        .add(msg.toFirestore());

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversation.id)
        .update({
      'lastMessage': type == MessageType.text ? content : '📷 Image',
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
        IconButton(
        icon: Icon(Icons.image, color: Colors.green.shade700),
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
          );

          if (result != null && result.files.single.path != null) {
            final image = File(result.files.single.path!);
            await _sendMessage(image: image);
          }
        },
      ),

            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.green.shade700),
              onPressed: () async {
                if (_messageController.text.trim().isNotEmpty) {
                  await _sendMessage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
