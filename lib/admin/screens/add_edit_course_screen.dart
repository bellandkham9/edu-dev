import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AddEditCourseScreen extends StatefulWidget {
  final String? courseId;
  final QueryDocumentSnapshot? courseData;

  const AddEditCourseScreen({super.key, this.courseId, this.courseData});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final contentCtrl = TextEditingController();

  String selectedContentType = 'text';
  List<Map<String, dynamic>> contents = [];

  File? pickedImage;
  File? pickedVideo;
  String? videoUrl;

  @override
  void initState() {
    super.initState();

    if (widget.courseData != null) {
      titleCtrl.text = widget.courseData!['title'] ?? '';
      descCtrl.text = widget.courseData!['shortDescription'] ?? '';
      videoUrl = widget.courseData!['videoUrl'];

      final rawContents = widget.courseData!['contents'] ?? [];

      contents = rawContents.map<Map<String, dynamic>>((item) {
        // 🔁 ANCIEN FORMAT (String)
        if (item is String) {
          return {
            'type': 'text',
            'value': item,
          };
        }

        // ✅ NOUVEAU FORMAT (Map)
        if (item is Map<String, dynamic>) {
          return {
            'type': item['type'] ?? 'text',
            'value': item['value'] ?? '',
          };
        }

        return {
          'type': 'text',
          'value': '',
        };
      }).toList();
    }
  }

  // 📸 Image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  // 🎥 Vidéo
  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedVideo = File(picked.path));
    }
  }

  // ☁️ Upload Storage
  Future<String> uploadFile(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }



  Future<String> uploadToCloudinary({
    required File file,
    required String resourceType, // image | video
  }) async {
    const cloudName = "dltpbxntn";
    const uploadPreset = "UPLOAD_PRESET";

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final data = json.decode(resBody);

    if (response.statusCode != 200) {
      throw Exception(data['error']['message']);
    }

    return data['secure_url'];
  }


  // 💾 Sauvegarde cours
  Future<void> saveCourse() async {
    final data = {
      'title': titleCtrl.text,
      'shortDescription': descCtrl.text,
      'videoUrl': videoUrl,
      'contents': contents,
      'createdAt': widget.courseId == null
          ? FieldValue.serverTimestamp()
          : widget.courseData!['createdAt'],
    };

    final ref = FirebaseFirestore.instance.collection('courses');

    widget.courseId == null
        ? await ref.add(data)
        : await ref.doc(widget.courseId).update(data);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseId == null ? "Ajouter un cours" : "Modifier le cours",
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔤 Infos du cours
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Titre"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 🎥 Vidéo
            ElevatedButton.icon(
              onPressed: () async {
                await pickVideo();
                if (pickedVideo != null) {
                  videoUrl = await uploadToCloudinary(
                    file: pickedVideo!,
                    resourceType: "video",
                  );
                  setState(() {});
                }

              },
              icon: const Icon(Icons.video_library),
              label: const Text("Uploader la vidéo"),
            ),

            if (videoUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.play_circle, size: 40, color: Colors.green),
                  Text("Vidéo uploadée avec succès"),
                ],
              ),

            const Divider(height: 30),

            // 📚 Contenus
            TextField(
              controller: contentCtrl,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: "Contenu texte",
                border: OutlineInputBorder(),
              ),
            ),

            DropdownButton<String>(
              value: selectedContentType,
              items: const [
                DropdownMenuItem(value: 'text', child: Text("Texte")),
                DropdownMenuItem(value: 'image', child: Text("Image")),
              ],
              onChanged: (value) {
                setState(() => selectedContentType = value!);
              },
            ),

            if (selectedContentType == 'text')
              TextField(
                controller: contentCtrl,
                decoration:
                const InputDecoration(labelText: "Contenu texte"),
              ),

            if (selectedContentType == 'image')
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Choisir une image"),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (selectedContentType == 'text' &&
                    contentCtrl.text.isNotEmpty) {
                  contents.add({
                    'type': 'text',
                    'value': contentCtrl.text,
                  });
                  contentCtrl.clear();
                }

                if (selectedContentType == 'image' && pickedImage != null) {
                  final url = await uploadToCloudinary(
                    file: pickedImage!,
                    resourceType: "image",
                  );
                  if (pickedImage != null) {
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.file(
                        pickedImage!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  }

                contents.add({
                    'type': 'image',
                    'value': url,
                  });

                  pickedImage = null;
                }


                setState(() {});
              },
              child: Icon(Icons.add, size: 24, color: Colors.orange,),
            ),

            const SizedBox(height: 20),

            // 📋 Liste contenus
            ...contents.map(
                  (c) => ListTile(
                leading: Icon(
                  c['type'] == 'text'
                      ? Icons.text_fields
                      : Icons.image,
                ),
                title: Text(
                  c['type'] == 'text' ? c['value'] : "Image",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() => contents.remove(c));
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 💾 Save
            ElevatedButton(
              onPressed: saveCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text("Enregistrer",style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
