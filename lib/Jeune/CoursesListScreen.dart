import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/course_card_grid.dart';
import '../../widgets/top_search_bar.dart';
import '../database/Cours.dart';
import '../theme/colors.dart';
import 'CourseDetailScreen.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Container(
              width: MediaQuery.of(context).size.width*0.9,
              child: const TopSearchBar(menuHint: false)),
          SizedBox(height: MediaQuery.of(context).size.height*0.02,),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('courses') // <-- ta collection Firestore
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucun cours disponible"));
                }

                // Transformer les documents en objets Course
                final courses = snapshot.data!.docs
                    .map((doc) => Course.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];

                    // Trouver la première image
                    final imageContent = course.contents.firstWhere(
                          (c) => c.type == 'image',
                      orElse: () => ContentItem(type: 'image', value: ''),
                    );

                    return CourseCardGrid(
                      title: course.title,
                      subtitle: course.shortDescription,
                      imageUrl: imageContent.value.isNotEmpty ? imageContent.value : null,
                      videoUrl: course.videoUrl, // utilisé si pas d'image
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(course: course),
                        ),
                      ),
                    );
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}
