import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu/admin/screens/AdminQuizPage.dart';
import 'package:flutter/material.dart';

import '../../Connexion/login.dart';
import 'add_edit_course_screen.dart';

class AdminCoursesScreen extends StatelessWidget {
  const AdminCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Admin - Cours",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {
    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
    );
    }, icon: Icon(Icons.logout_outlined))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add,color: Colors.white,),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditCourseScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(Icons.folder),
                  title: Text(course['title']),
                  subtitle: Text(course['shortDescription']),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text("Modifier"),
                      ),
                      const PopupMenuItem(
                        value: 'quiz',
                        child: Text("Gérer les quiz"),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Supprimer"),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditCourseScreen(
                              courseId: course.id,
                              courseData: course,
                            ),
                          ),
                        );
                      }
                      if (value == 'quiz') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminQuizPage(
                              courseId: course.id,
                            ),
                          ),
                        );
                      }
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text(
                              'Voulez-vous vraiment supprimer ce cours ?\n'
                                  'Cette action est irréversible.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // fermer la boîte
                                },
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context); // fermer la boîte

                                  await FirebaseFirestore.instance
                                      .collection('courses')
                                      .doc(course.id)
                                      .delete();
                                },
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                      }

                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
